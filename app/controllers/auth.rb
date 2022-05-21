# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, auth sub-route
  class Api < Roda
    route('auth') do |routing|

      # POST api/v1/auth/register
      routing.post 'register' do
        # POST api/v1/auth/register
        reg_data = JsonRequestBody.parse_symbolize(request.body.read)
        VerifyRegistration.new(reg_data).call

        response.status = 202
        { message: 'Verification email sent' }.to_json
      rescue VerifyRegistration::InvalidRegistration => e
        routing.halt 400, { message: e.message }.to_json
      rescue VerifyRegistration::EmailProviderError
        routing.halt 500, { message: 'Error sending email' }.to_json
      rescue StandardError => e
        Api.logger.error "Could not verify registration: #{e.inspect}"
        routing.halt 500
      end

      routing.is 'authenticate' do
        # POST api/v1/auth/authenticate
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          Api.logger.error [e.class, e.message].join ': '
          routing.halt 403, { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
