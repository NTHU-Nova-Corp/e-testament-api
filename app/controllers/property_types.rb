# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('property_types') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @properties_route = "#{@account_route}/properties"
      @heirs_route = "#{@api_root}/property_types"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      # POST api/v1/property_types
      # Hasn't been used yet
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_property_type = Services::PropertyType::CreatePropertyType.call(new_data:)
        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_property_type.id}"
        { message: 'Property type saved', data: new_property_type }.to_json
      end

      # GET api/v1/property_types
      routing.get do
        output = Services::PropertyType::GetPropertyTypes.call
        { data: output }.to_json
      end
    end
  end
end
