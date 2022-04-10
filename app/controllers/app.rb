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

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'properties' do
            routing.on String do |property_id|
              routing.on 'documents' do
                routing.on String do |property_id|
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
              # TODO Cesar
            end

            # POST api/v1/properties
            # Creates a new property
            # TODO Cesar

            # GET api/v1/properties
            # Gets the list of properties
            # TODO Cesar
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
