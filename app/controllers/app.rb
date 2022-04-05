# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/property'

# General ETestament module
module ETestament
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Property.setup
    end
    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        response.status = 200
        { message: 'ETestamentAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'properties' do
            # GET api/v1/properties/[id]
            # Get a specific property record
            # TODO: Daniel

            # GET api/v1/properties
            # Get the list of properties indexes
            # TODO: Cesar

            # POST api/v1/properties
            # Creates a new property
            # TODO: Ernesto
          end
        end
      end
    end
  end
end
