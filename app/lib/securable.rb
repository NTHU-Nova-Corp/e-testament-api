# frozen_string_literal: true

require 'base64'
require 'rbnacl'

# Crypto methods for mixin
module Securable
  class NoKeyError < StandardError; end

  # Generate key for Rake tasks (typically not called at runtime)
  def generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64(key)
  end

  # We only call this once with the generated key
  def setup(base_key)
    raise NoKeyError unless base_key

    @base_key = base_key
  end

  def key
    # We only store the key if we don't have a key yet
    # Otherwise, just return the stored value
    @key ||= Base64.strict_decode64(@base_key)
  end

  def base_encrypt(plaintext)
    # NOTE: key below is a method in the mixin
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.encrypt(plaintext)
  end

  def base_decrypt(ciphertext)
    # NOTE: key below is a method in the mixin
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.decrypt(ciphertext).force_encoding(Encoding::UTF_8)
  end
end