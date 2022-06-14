# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('executors') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @executors_route = "#{@api_root}/executors"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @account_id = @auth_account['id']

      routing.on 'sent' do
        # GET api/v1/testators/sent
        # Returns the list of executor requests pending to be accepted by the current account
        routing.get do
          output = Services::Executors::GetSentExecutor.call(id: @account_id)
          { data: output }.to_json
        end
      end

      # GET api/v1/executors
      # Get request list for being executors list
      routing.get do
        output = Services::Executors::GetExecutor.call(id: @account_id)
        { data: output }.to_json
      end

      # POST api/v1/executors
      # Sends a request to be executor
      routing.post do
        executor_data = JSON.parse(routing.body.read)
        Services::Executors::CreateExecutorRequest.call(account: @auth_account, executor_data:)
        response.status = 200
        { message: 'Executor Request Sent' }.to_json
      end
    end
  end
end
