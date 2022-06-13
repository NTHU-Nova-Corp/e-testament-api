# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('testators') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @testators_route = "#{@api_root}/testators"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @account_id = @auth_account['id']

      routing.on String do |testator_id|
        # GET api/v1/testator/:testator_id/heirs
        # Get all heirs of a testator
        routing.get 'heirs' do
          output = Services::Heirs::GetHeirs.call(requester: @auth_account, account_id: testator_id)
          { data: output }.to_json
        end

        # GET api/v1/testator/:testator_id
        # Get testator's info
        routing.get do
          output = Services::Accounts::GetTestator.call(id: @account_id, testator_id:)
          { data: output }.to_json
        end
      end

      #  GET api/v1/testators :: Get all testators
      routing.get do
        output = Services::Accounts::GetTestators.call(id: @account_id)
        { data: output }.to_json
      end
    end
  end
end
