# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('property_types') do |routing|
      @account_id = '70b4347a-d2bc-45f8-9d12-b1047126cb55' # TODO: This will came from the headers in the api
      # Web controller for ETestament API, heirs sub-route
      @heirs_route = "#{@api_root}/property_types"

      routing.on String do |_property_type_id|
        # TODO: POST api/v1/property_types/[property_type_id]/delete
        # TODO Should not enable to delete if there is any property related with
        routing.post 'delete' do
        end

        # TODO: POST api/v1/property_types/[property_type_id]/edit
        routing.post 'edit' do
        end

        # TODO: POST api/v1/property_types/[property_type_id]
        routing.post do
        end

        # TODO: GET api/v1/property_types/[property_type_id]
        routing.get do
        end
      end

      # TODO: POST api/v1/property_types
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_property_type = PropertyType.new(new_data)
        raise BadRequestException, 'Could not save property type' unless new_property_type.save

        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_property_type.id}"
        { message: 'Property type saved', data: new_property_type }.to_json
      end

      # TODO: GET api/v1/property_types
      routing.get do
        # Heir.where(:account_id)
      end
    end
  end
end
