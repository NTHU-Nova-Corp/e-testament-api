# frozen_string_literal: true

require_relative './app'
require 'google/apis/gmail_v1'

# General ETestament module
module ETestament
  # Web controller for ETestament API, auth sub-route
  class Api < Roda
    route('auth') do |routing|
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      # POST api/v1/auth/register
      routing.post 'register' do
        Services::Accounts::VerifyRegistration.new(@request_data).call

        response.status = 202
        { message: 'Verification email sent' }.to_json
      rescue Exceptions::BadRequestError => e
        routing.halt 400, { message: e.message }.to_json
      rescue Exceptions::EmailProviderError
        routing.halt 500, { message: 'Error sending email' }.to_json
      rescue StandardError => e
        Api.logger.error "Could not verify registration: #{e.inspect}" if ETestament::Api.environment == :production
        routing.halt 500
      end

      routing.is 'authenticate' do
        # POST api/v1/auth/authenticate
        routing.post do
          auth_account = Services::Accounts::Authenticate.call(@request_data)
          { data: auth_account }.to_json
        rescue Exceptions::UnauthorizedError => e
          Api.logger.error [e.class, e.message].join ': ' if ETestament::Api.environment == :production
          routing.halt '401', { message: 'Invalid credentials' }.to_json
        end
      end

      routing.is 'authenticate-google' do
        # POST /api/v1/auth/authenticate-google
        routing.post do
          auth_account = Services::Accounts::AuthenticateGoogle.call(@request_data)
          { data: auth_account }.to_json

        rescue Exceptions::UnauthorizedError => e
          Api.logger.error [e.class, e.message].join ': ' if ETestament::Api.environment == :production
          routing.halt 403, { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
