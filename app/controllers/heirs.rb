# frozen_string_literal: true

require 'roda'
require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    plugin :request_headers
    # Web controller for ETestament API, heirs sub-route
    route('heirs') do |routing|
      @heirs_route = "#{@api_root}/heirs"

      routing.on String do |heir_id|
        routing.on 'properties' do
          routing.on String do |property_id|
            @heirs_property_route = "#{@heirs_route}/#{heir_id}/properties/#{property_id}"
            # POST api/v1/heirs/[heir_id]/properties/[property_id]/delete
            # TODO: Unit-test
            routing.post 'delete' do
              Services::Heirs::DeleteProperty(heir_id:, property_id:)

              response.status = 200
              response['Location'] = "#{@properties_route}/#{property_id}"
              { message: 'Property has been deleted' }.to_json
            end

            # POST api/v1/heirs/[heir_id]/properties/[property_id]
            # TODO: Unit-test
            routing.post do
              new_data = JSON.parse(routing.body.read)
              result = Services::Heirs::AddPropertyHeir.call(new_data)

              response.status = 201
              response['Location'] = @heirs_property_route.to_s
              { message: 'Property associated with the heir', data: result }.to_json
            end

            # GET api/v1/heirs/[heir_id]/properties/[property_id]
            # TODO: Unit-test
            routing.get do
              Services::Heirs::GetProperty(heir_id:, property_id:)
            end
          end

          # GET api/v1/heirs/[heir_id]/properties
          routing.get do
            Services::Heirs::GetProperties.call(heir_id:)
          end
        end

        # POST api/v1/heirs/[heir_id]/delete
        # Nice to have :: Rollback PropertyHeir when deleting Heir wrongly
        routing.post 'delete' do
          Services::Heirs::DeleteHeirsFromProperty.call(heir_id:)
          response.status = 200
          response['Location'] = "#{@heirs_route}/#{heir_id}"
          { message: 'Heir has been deleted' }.to_json
        end

        # POST api/v1/heirs/[heir_id]
        # Updates existing heir
        routing.post do
          updated_data = JSON.parse(routing.body.read)
          Services::Heirs::UpdateHeir.call(id: heir_id, updated_data:)

          response.status = 200
          response['Location'] = "#{@heirs_route}/#{heir_id}"
          { message: 'Heir is updated', data: updated_data }.to_json
        end

        # GET api/v1/heirs/[heir_id]
        routing.get do
          Services::Heirs::GetHeir.call(id: heir_id)
        end
      end

      # POST api/v1/heirs
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_heir = Services::Heirs::CreateHeir.call(id: @auth_account['id'], new_data:)

        response.status = 201
        response['Location'] = "#{@heirs_route}/#{new_heir.id}"
        { message: 'Heir saved', data: new_heir }.to_json
      end

      # GET api/v1/heirs
      routing.get do
        Services::Heirs::GetHeirs.call(account_id: @auth_account['id'])
      rescue StandardError
        raise Exceptions::NotFoundError('Could not find heirs')
      end
    end
  end
end
