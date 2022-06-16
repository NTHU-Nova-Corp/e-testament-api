# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('testators') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @testators_route = "#{@api_root}/testators"

      routing.on 'submit-key' do
        routing.post do
          key_data = JSON.parse(routing.body.read)
          output = Services::Testators::SubmitHeirKey.call(heir_id: key_data['heir_id'],
                                                           key_content_submitted: key_data['heir_key'])
          { data: output }.to_json
        end
      end

      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @account_id = @auth_account['id']

      routing.on 'request' do
        # GET api/v1/testators/request
        # Returns the list of executor requests pending to be accepted by the current account
        routing.get do
          output = Services::Testators::GetRequestTestator.call(id: @account_id)
          { data: output }.to_json
        end
      end

      routing.on String do |testator_id|
        # GET api/v1/testator/:testator_id/heirs
        # Get all heirs of a testator
        routing.get 'heirs' do
          output = Services::Heirs::GetHeirs.call(requester: @auth_account, account_id: testator_id)
          { data: output }.to_json
        end

        # POST api/v1/testators/:testator_id/accept
        # Accepts the request to be executor by a testator
        routing.post 'accept' do
          Services::Testators::AcceptTestatorRequest.call(owner_account_id: testator_id,
                                                          executor_account_id: @account_id)
          { message: 'Testator Request Accepted' }.to_json
        end

        # POST api/v1/testators/:testator_id/reject
        # Rejects the request to be executor by a testator
        routing.post 'reject' do
          Services::Testators::RejectTestatorRequest.call(owner_account_id: testator_id,
                                                          executor_account_id: @account_id)
          { message: 'Testator Request Rejected' }.to_json
        end

        # POST api/v1/testators/:testator_id/release
        # Releases the request to be executor by a testator
        routing.post 'release' do
          Services::Testators::ReleaseTestatorTestament.call(requester: @auth_account, testator_id:)
          { message: 'Testator Testament Released' }.to_json
        end

        # POST api/v1/testators/:testator_id/read
        # Releases the request to be executor by a testator
        routing.post 'read' do
          Services::Testators::ReadTestatorTestament.call(owner_account_id: testator_id,
                                                          executor_account_id: @account_id)
          { message: 'Testator Testament Read' }.to_json
        end

        # GET api/v1/testator/:testator_id/testament
        # Get testator's testament info
        routing.get 'testament' do
          output = Services::PropertyHeirs::GetPropertiesWithHeirsDistribution.call(requester: @auth_account,
                                                                                    account_id: testator_id)
          JSON({ data: output }, {})
        end

        # GET api/v1/testator/:testator_id
        # Get testator's info
        routing.get do
          output = Services::Testators::GetTestator.call(id: @account_id, testator_id:)
          { data: output }.to_json
        end
      end

      #  GET api/v1/testators :: Get all testators
      routing.get do
        output = Services::Testators::GetTestators.call(id: @account_id)
        { data: output }.to_json
      end
    end
  end
end
