# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, accounts sub-route
  class Api < Roda
    # api/v1/accounts
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on 'executors' do
        # GET api/v1/accounts/executors
        # Sends a request to be executor
        # TODO: Add unit-test
        routing.get do
          Services::Accounts::GetExecutorAccount.call(id: @auth_account['id'])
        end

        # POST api/v1/accounts/executors
        # Sends a request to be executor
        # TODO: Add unit-test
        routing.post do
          executor_data = JSON.parse(routing.body.read)
          Services::Accounts::CreateExecutorRequest.call(executor_data:)
          response.status = 200
          { message: 'Executor Request Sent' }.to_json
        end
      end

      routing.on 'testors' do
        routing.on 'pending-requests' do
          # GET api/v1/accounts/testors/pending-requests
          # Returns the list of executor requests pending to be accepted by the current account
          # TODO: Add unit-test
          routing.get do
            output = Services::Accounts::GetExecutorAccount.call(id: @auth_account['id'])
            JSON.pretty_generate(output)
          end
        end

        routing.on String do |testor_id|
          # POST api/v1/accounts/testors/:testor_id/accept
          # Accepts the request to be executor by a testor
          # TODO: Add unit-test
          routing.post 'accept' do
            Services::Accounts::AcceptTestorRequest.call(owner_account_id: testor_id,
                                                         executor_account_id: @auth_account['id'])
            { message: 'Testor Request Accepted' }.to_json
          end

          # POST api/v1/accounts/testors/:testor_id/reject
          # Rejects the request to be executor by a testor
          # TODO: Add unit-test
          routing.post 'reject' do
            Services::Accounts::RejectTestorRequest.call(owner_account_id: testor_id,
                                                         executor_account_id: @auth_account['id'])
            { message: 'Testor Request Rejected' }.to_json
          end
        end
      end

      # GET api/v1/accounts/:username
      # Get account profile by username
      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          Services::Accounts::GetAccount.call(username:)
        end
      end

      # POST api/v1/accounts
      # Create new account
      # TODO: Update unittest
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Services::Accounts::CreateAccount.call(new_data:)

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
