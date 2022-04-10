# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../exception/bad_request_exception'
require_relative '../exception/pre_condition_required_exception'

# General ETestament module
module ETestament
  # Web controller for ETestament API
  class Api < Roda
    # plugin :environments
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        response.status = 200
        { message: 'ETestamentAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'properties' do
          @properties_route = "#{@api_root}/properties"
          routing.on String do |property_id|
            routing.on 'documents' do
              routing.on String do |document_id|
                # DELETE api/v1/properties/[property_id]/documents/[document_id]
                # Deleted a document related with a property
                # TODO Daniel

                # PUT api/v1/properties/[property_id]/documents/[document_id]
                # Updates a document related with a property
                # TODO Daniel

                # GET api/v1/properties/[property_id]/documents/[document_id]
                # Gets an specific document related with a property
                # TODO Daniel
              end

              # POST api/v1/properties/[property_id]/documents
              # Creates a new document related with a property
              # TODO Daniel

              # GET api/v1/properties/[property_id]/documents
              # Gets the list of documents related with a proeprty
              # TODO Ernesto
            end

            # DELETE api/v1/properties/[property_id]
            # Deleted an existing property and the documents related with
            # TODO Ernesto

            # PUT api/v1/properties/[property_id]
            # Updates an existing property
            # TODO Ernesto

            # GET api/v1/properties/[property_id]
            # Get a specific property record
            routing.get do
              property = Property.first(id: property_id)
              property ? property.to_json : raise('Property not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # POST api/v1/properties
          # Creates a new property
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_property = Property.new(new_data)
            raise('Could not save property') unless new_property.save

            response.status = 201
            response['Location'] = "#{@properties_route}/#{new_property.id}"
            { message: 'Property saved', data: new_property }.to_json
          end

          # GET api/v1/properties
          # Gets the list of properties
          routing.get do
            output = { data: Property.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find properties' }.to_json
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
