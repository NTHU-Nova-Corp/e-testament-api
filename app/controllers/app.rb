# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../exception/bad_request_exception'
require_relative '../exception/pre_condition_required_exception'

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
            routing.get String do |id|
              Property.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Property not found' }.to_json
            end

            # GET api/v1/properties
            # Get the list of properties indexes
            routing.get do
              response.status = 200
              output = { property_ids: Property.all }

              JSON.pretty_generate(output)
            end

            # POST api/v1/properties
            # Creates a new property
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_property = Property.new(new_data)
              new_property.save

              response.status = 201
              { message: 'Property saved', id: new_property.id }.to_json
            end
          end

        rescue PreConditionRequireException => e
          routing.halt 428, { code: 428, message: "Error: #{e.message}" }.to_json

        rescue BadRequestException, JSON::ParserError => e
          routing.halt 400, { code: 400, message: "Error: #{e.message}" }.to_json

        rescue StandardError => e
          routing.halt 500, { code: 500, message: "Error: #{e.message}" }.to_json
        end
      end
    end
  end
end
