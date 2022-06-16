# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, accounts sub-route
  class Api < Roda
    # api/v1/accounts
    route('accounts') do |routing|
      @account_id = @auth_account['id']
      @account_route = "#{@api_root}/accounts"

      # GET api/v1/accounts/:username
      # Get account profile by username
      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          output = Services::Accounts::GetAccount.call(requester: @auth_account, username:)
          { data: output }.to_json
        end
      end

      # POST api/v1/accounts
      # Create new account
      # TODO: Update unittest
      routing.post do
        new_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_account = Services::Accounts::CreateAccount.call(new_data:)

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{account_data.keys}" if ETestament::Api.environment == :production
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue SignedRequest::VerificationError
        routing.halt 403, { message: 'Must sign request' }.to_json
      rescue StandardError => e
        Api.logger.error e.message if ETestament::Api.environment == :production
        routing.halt 500, { message: 'Error creating account' }.to_json
      end
    end
  end
end
