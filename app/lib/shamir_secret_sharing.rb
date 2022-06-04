# frozen_string_literal: true

require 'openssl'
require 'rbnacl'

module ShamirEncryption
  # ShamirSecretSharing
  # rubocop:disable Metrics/ClassLength
  class ShamirSecretSharing
    VERSION = '0.0.1'

    def self.pack(shares)
      shares
    end

    def self.unpack(shares)
      shares
    end

    def self.encode(string)
      string
    end

    def self.decode(string)
      string
    end

    def self.smallest_prime_of_bytelength(bytelength)
      n = OpenSSL::BN.new(((2**(bytelength * 8)) + 1).to_s)
      loop do
        break if n.prime_fasttest?(20)

        n += 2
      end
      n
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def self.split(secret, available, needed)
      do_data_checksum = true
      raise ArgumentError, 'needed must be <= available' unless needed <= available
      raise ArgumentError, 'needed must be >= 2' unless needed >= 2
      raise ArgumentError, 'available must be <= 250' unless available <= 250

      if do_data_checksum
        checksum = RbNaCl::Hash.sha512(secret)[0...2]
        num_bytes = secret.bytesize + 2
        secret = begin
          OpenSSL::BN.new((checksum + secret).unpack1('H*'), 16)
        rescue StandardError
          OpenSSL::BN.new('0')
        end
        raise ArgumentError, 'bytelength of secret must be >= 1' if num_bytes < 3
        raise ArgumentError, 'bytelength of secret must be <= 512' if num_bytes > 513
      else
        num_bytes = secret.bytesize
        secret = begin
          OpenSSL::BN.new(secret.unpack1('H*'), 16)
        rescue StandardError
          OpenSSL::BN.new('0')
        end
        raise ArgumentError, 'bytelength of secret must be >= 1' if num_bytes < 1
        raise ArgumentError, 'bytelength of secret must be <= 512' if num_bytes > 512
      end

      prime = smallest_prime_of_bytelength(num_bytes)
      coef = [secret] + Array.new(needed - 1) { OpenSSL::BN.rand(num_bytes * 8) }

      shares = (1..available).map do |x|
        x = OpenSSL::BN.new(x.to_s)
        y = coef.each_with_index.inject(OpenSSL::BN.new('0')) do |acc, (c, idx)|
          acc + (c * x.mod_exp(idx, prime))
        end % prime
        [x, num_bytes, y]
      end
      pack(shares)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.combine(shares, do_raise: false, do_data_checksum: true)
      return false if shares.size < 2

      shares = unpack(shares)
      num_bytes = shares[0][1]
      prime = smallest_prime_of_bytelength(num_bytes)

      secret = shares.inject(OpenSSL::BN.new('0')) do |secret, (x, _num_bytes, y)|
        l_x = l(x, shares, prime)
        summand = OpenSSL::BN.new(y.to_s).mod_mul(l_x, prime)
        (secret + summand) % prime
      end
      if do_data_checksum
        _, secret = [secret.to_s(16).rjust(num_bytes * 2, '0')].pack('H*').unpack('a2a*')
        RbNaCl::Hash.sha512(secret)[0...2] ? secret : false
      else
        [secret.to_s(16).rjust(num_bytes * 2, '0')].pack('H*')
      end
    rescue ShareChecksumError, ShareDecodeError
      raise if do_raise

      false
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # Part of the Lagrange interpolation.
    # This is l_j(0), i.e.  # \prod_{x_j \neq x_i} \frac{-x_i}{x_j - x_i}
    # for more information compare Wikipedia: # http://en.wikipedia.org/wiki/Lagrange_form
    def self.l(current_x, shares, prime)
      rejected_shared = shares.reject { |x, _num_bytes, _y| x == current_x }.map do |x, _num_bytes, _y|
        minus_xi = OpenSSL::BN.new((-x).to_s)
        one_over_xj_minus_xi = OpenSSL::BN.new((current_x - x).to_s).mod_inverse(prime)
        minus_xi.mod_mul(one_over_xj_minus_xi, prime)
      end
      rejected_shared.inject { |p, f| p.mod_mul(f, prime) }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    def self.split_with_sanity_check(secret, available, needed)
      shares = split(secret, available, needed)
      success = true
      needed.upto(available).each do |n|
        shares.permutation(n).each do |s|
          success = false if combine(s) != secret
        end
      end
      (needed - 1).downto(2).each do |n|
        shares.permutation(n).each do |s|
          success = false if combine(s) != false
        end
      end
      raise ShareSanityCheckError if success != true

      shares
    rescue ShareSanityCheckError
      retry
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

    class ShareChecksumError < ::StandardError; end

    class ShareDecodeError < ::StandardError; end

    class ShareSanityCheckError < ::StandardError; end

    # packing format and checkum
    class Packed < ShamirSecretSharing
      def self.pack(shares)
        shares.map do |x, num_bytes, y|
          buf = [x, num_bytes, y.to_s(16)].pack('CnH*')
          checksum = RbNaCl::Hash.sha512(buf)[0...2]
          # checksum = Digest::SHA512.digest(buf)[0...2]
          encode(checksum << buf)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def self.unpack(shares)
        shares.map do |i|
          buf = begin
            decode(i)
          rescue StandardError
            nil
          end
          raise ShareDecodeError, "share: #{i}" unless buf

          checksum, buf = buf.unpack('a2a*')
          raise ShareChecksumError, "share: #{i}" unless checksum == Digest::SHA512.digest(buf)[0...2]

          i = buf.unpack('CnH*')
          [i[0], i[1], i[2].to_i(16)]
        end
      end
      # rubocop:enable Metrics/MethodLength
    end

    # Base64
    class Base64 < Packed
      def self.encode(string)
        [string].pack('m0')
      end

      def self.decode(string)
        string.unpack1('m0')
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
