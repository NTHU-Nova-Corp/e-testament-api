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
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      routing.on String do |heir_id|
        @heir = Heir.first(id: heir_id)
        raise Exceptions::NotFoundError, 'Heir not found' if @heir.nil?

        routing.on 'properties' do
          routing.on String do |property_id|
            @property = Property.first(id: property_id)
            raise Exceptions::NotFoundError, 'Property not found' if @property.nil?

            @heirs_property_route = "#{@heirs_route}/#{heir_id}/properties/#{property_id}"
            # POST api/v1/heirs/:heir_id/properties/:property_id/delete
            routing.post 'delete' do
              Services::PropertyHeirs::DeleteAssociationBetweenPropertyAndHeir.call(requester: @auth_account,
                                                                                    heir_data: @heir,
                                                                                    property_data: @property)

              response.status = 200
              response['Location'] = "#{@properties_route}/#{property_id}"
              { message: 'Property has been deleted' }.to_json
            end

            # POST api/v1/heirs/:heir_id/properties/:property_id
            routing.post do
              new_data = JSON.parse(routing.body.read)
              result = Services::PropertyHeirs::AssociatePropertyHeir.call(requester: @auth_account, heir_data: @heir,
                                                                           property_data: @property, new_data:)

              response.status = 201
              response['Location'] = @heirs_property_route.to_s
              { message: 'Property associated with the heir', data: result }.to_json
            end
          end

          # GET api/v1/heirs/:heir_id/properties
          routing.get do
            output = Services::PropertyHeirs::GetPropertiesAssociatedToHeir.call(requester: @auth_account,
                                                                                 heir_data: @heir)
            { data: output }.to_json
          end
        end

        # POST api/v1/heirs/:heir_id/delete
        # * Nice to have :: Rollback PropertyHeir when deleting Heir wrongly
        routing.post 'delete' do
          Services::Heirs::DeleteHeir.call(requester: @auth_account, heir_data: @heir)
          response.status = 200
          response['Location'] = "#{@heirs_route}/#{heir_id}"
          { message: 'Heir has been deleted' }.to_json
        end

        # POST api/v1/heirs/:heir_id
        # Updates existing heir
        routing.post do
          updated_data = JSON.parse(routing.body.read)
          Services::Heirs::UpdateHeir.call(requester: @auth_account, heir_data: @heir, updated_data:)

          response.status = 200
          response['Location'] = "#{@heirs_route}/#{heir_id}"
          { message: 'Heir is updated', data: updated_data }.to_json
        end

        # GET api/v1/heirs/:heir_id
        routing.get do
          output = Services::Heirs::GetHeir.call(requester: @auth_account, heir_data: @heir)
          { data: output }.to_json
        end
      end

      # POST api/v1/heirs
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_heir = Services::Heirs::CreateHeir.call(requester: @auth_account,
                                                    account_id: @auth_account['id'], new_data:)

        response.status = 201
        response['Location'] = "#{@heirs_route}/#{new_heir.id}"
        { message: 'Heir saved', data: new_heir }.to_json
      end

      # GET api/v1/heirs
      routing.get do
        output = Services::Heirs::GetHeirs.call(requester: @auth_account, account_id: @auth_account['id'])
        { data: output }.to_json
      rescue StandardError
        raise Exceptions::NotFoundError('Could not find heirs')
      end
    end
  end
end
