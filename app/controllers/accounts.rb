# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, accounts sub-route
  class Api < Roda
    # api/v1/accounts
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      # POST api/v1/accounts/executors
      # Sends a request to be executor
      routing.post 'executors' do
        executor_data = JSON.parse(routing.body.read)
        executor_pending = PendingExecutorAccount.new({ executor_email: executor_data['email'] })
        executor_pending.owner_account_id = @auth_account['id']
        executor_account = Account.first(email: executor_data['email'])
        PendingExecutorAccount.where(owner_account_id: @auth_account['id']).delete

        if executor_account.nil?
          VerifyRegistration.new({
                                   verification_url: executor_data['verification_url'],
                                   username: executor_data['email'],
                                   email: executor_data['email']
                                 }).call
        else
          executor_pending.executor_account_id = executor_account.id
        end

        executor_pending.save
        response.status = 200
        { message: 'Executor Request Sent' }.to_json
      end

      routing.on 'testors' do
        routing.on 'pending-requests' do
          # TODO: GET api/v1/accounts/testors/pending-requests
          # Returns the list of executor requests pending to be accepted by the current account
          routing.get do
          end
        end

        routing.on String do |_testor_id|
          # TODO: POST api/v1/accounts/testors/:testor_id/accept
          # Accepts the request to be executor by a testor
          routing.post 'accept' do
          end

          # TODO: POST api/v1/accounts/testors/:testor_id/reject
          # Rejects the request to be executor by a testor
          routing.post 'reject' do
          end
        end
      end

      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          account = Account.first(username:)
          raise NotFoundException, 'Account not found.' if account.nil?

          account.to_json
        end
      end

      routing.post do
        # POST api/v1/accounts
        new_data = JSON.parse(routing.body.read)
        raise 'Username exists' unless Account.first(username: new_data['username']).nil?

        new_account = Account.new(new_data)
        raise 'Could not save account' unless new_account.save

        PendingExecutorAccount.where(executor_email: new_account.email).update(executor_account_id: new_account.id)

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
