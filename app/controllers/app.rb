# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../exception/bad_request_exception'
require_relative '../exception/pre_condition_required_exception'

require_relative '../models/property'

# General ETestament module
module ETestament
  # Web controller for ETestament API
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
            # GET api/v1/properties/[property_id]
            # Get a specific property record
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

            # PUT api/v1/properties/[property_id]
            # Updates an existing property
            # TODO Cesar

            # DELETE api/v1/properties/[property_id]
            # Deleted an existing property and the documents related with
            # TODO Cesar

            routing.on 'documents' do
              # GET api/v1/properties/[property_id]/documents/[document_id]
              # Gets an specific document related with a property
              # TODO Ernesto

              # GET api/v1/properties/[property_id]/documents
              # Gets the list of documents related with a proeprty
              # TODO Ernesto

              # POST api/v1/properties/[property_id]/documents/[document_id]
              # Creates a new document related with a property
              # TODO Daniel

              # PUT api/v1/properties/[property_id]/documents/[document_id]
              # Updates a document related with a property
              # TODO Daniel

              # DELETE api/v1/properties/[property_id]/documents/[document_id]
              # Deleted a document related with a property
              # TODO Daniel
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
