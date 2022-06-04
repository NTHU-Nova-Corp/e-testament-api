# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, auth sub-route
  class Api < Roda
    route('auth') do |routing|
      # POST api/v1/auth/register
      routing.post 'register' do
        reg_data = JsonRequestBody.parse_symbolize(request.body.read)
        Services::Accounts::VerifyRegistration.new(reg_data).call

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
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = Services::Accounts::Authenticate.call(credentials)
          auth_account.to_json
        rescue Exceptions::UnauthorizedError => e
          Api.logger.error [e.class, e.message].join ': ' if ETestament::Api.environment == :production
          routing.halt 403, { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
