# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('property_types') do |routing|
      @account_id = 'ABC' # TODO: This will came from the headers in the api
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
      end

      # TODO: GET api/v1/property_types
      routing.get do
        # Heir.where(:account_id)
      end
    end
  end
end
