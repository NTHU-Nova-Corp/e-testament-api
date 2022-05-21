# frozen_literal_string: true

require 'base64'
require_relative 'securable'

## Token and Detokenize Authorization Info
# Usage examples
#  AuthToken.setup(AuthToken.generate_key)
#  token = AuthToken.create({ key: 'value', key2: 12 }, AuthToken::ONE_MONTH)
#  AuthToken.new(token).payload   # => {"key"=>"value", "key2"=>12}
class AuthToken
  extend Securable

  ONE_HOUR = 60 * 60
  ONE_DAY = 24 * ONE_HOUR
  ONE_WEEK = 7 * ONE_DAY
  ONE_MONTH = 4 * ONE_WEEK
  ONE_YEAR = 12 * ONE_MONTH

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end

  # Extract info from a token
  def initialize(token)
    @token = token
    contents = AuthToken.detokenize(token)
    @expiration = contents['exp']
    @payload = contents['payload']
  end

  # Check if token is expired
  def expired?
    Time.now > Time.at(@expiration)
  rescue StandardError
    raise InvalidTokenError
  end

  # Check if token is not expired
  # Optional syntactic sugar
  def fresh? = !expired?

  # Extract data from token
  def payload
    expired? ? raise(ExpiredTokenError) : @payload
  end

  def to_s = @token

  # Create a token from a Hash payload
  def self.create(payload, expiration = ONE_WEEK)
    contents = { 'payload' => payload, 'exp' => expires(expiration) }
  end

  def self.expires(expiration)
    (Time.now + expiration).to_i
  end

  # Tokenize contents or return nil if no data
  def self.tokenize(message)
    return nil unless message

    message_json = message.to_json
    ciphertext = base_encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  # Detokenize and return contents, or raise error
  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    message_json = base_decrypt(ciphertext)
    JSON.parse(message_json)
  rescue StandardError
    raise InvalidTokenError
  end
end