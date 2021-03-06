# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('testaments') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @testators_route = "#{@api_root}/testaments"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @account_id = @auth_account['id']

      #  POST api/v1/testaments/complete :: Sets the status of the testament as completed
      routing.post 'complete' do
        new_data = JSON.parse(routing.body.read)
        output = Services::Accounts::Testament::Complete.call(requester: @auth_account,
                                                              account_id: @account_id,
                                                              min_amount_heirs: new_data['min_amount_heirs'])
        { data: output }.to_json
      end

      #  POST api/v1/testaments/enable-edition :: Sets the status of the testament as completed
      routing.post 'enable-edition' do
        output = Services::Accounts::Testament::SetUnderEdition.call(requester: @auth_account,
                                                                     account_id: @account_id)
        { data: output }.to_json
      end

      #  GET api/v1/testaments :: Get the testament distribution report
      routing.get do
        output = Services::PropertyHeirs::GetPropertiesWithHeirsDistribution.call(requester: @auth_account,
                                                                                  account_id: @account_id)
        JSON({ data: output }, {})
      end
    end
  end
end
