# frozen_literal_string: true

require_relative 'securable'
require_relative 'shamir_secret_sharing'

class KeySplitter
  extend Securable
  extend ShamirEncryption

  class InvalidKeyError < StandardError; end

  def self.get_key
    setup(generate_key)
  end

  def merge(shares)

  end

  def test
  end
end