# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../exception/bad_request_exception'
require_relative '../exception/not_found_exception'
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
              @documents_route = "#{@properties_route}/#{property_id}/documents"

              # DELETE api/v1/properties/[property_id]/documents/[document_id]/delete
              # Deleted a document related with a property
              routing.on String do |document_id|
                routing.on 'delete' do
                  routing.post do
                    current_document = Document.where(id: document_id, property_id:)
                    raise NotFoundException if current_document.first.nil?
                    raise('Could not delete document associated with property') unless current_document.delete

                    response.status = 200
                    response['Location'] = "#{@documents_route}/#{document_id}/delete"
                    { message: 'Document associated with property has been deleted' }.to_json
                  end
                end

                # PUT api/v1/properties/[property_id]/documents/[document_id]
                # Updates a document related with a property
                routing.post do
                  updated_data = JSON.parse(routing.body.read)
                  updated_data['updated_at'] = Time.now.to_s
                  update_result = Document.where(property_id:, id: document_id).update(updated_data)
                  raise NotFoundException if update_result.zero?

                  response.status = 200
                  response['Location'] = "#{@documents_route}/#{document_id}"
                  { message: 'Document is updated', data: updated_data }.to_json
                end

                # GET api/v1/properties/[property_id]/documents/[document_id]
                # Gets an specific document related with a property
                routing.get do
                  document = Document.first(id: document_id, property_id:)
                  raise NotFoundException if document.nil? || (document.property_id.to_s != property_id)

                  document.to_json
                end
              end
              # POST api/v1/properties/[property_id]/documents
              # Creates a new document related with a property
              routing.post do
                new_data = JSON.parse(routing.body.read)
                print(property_id)
                existing_property = Property.first(id: property_id)
                print(existing_property)
                new_document = existing_property.add_document(new_data)
                raise('Could not save document') unless new_document.save

                response.status = 201
                response['Location'] = "#{@documents_route}/#{new_document.id}"
                { message: 'Property saved', data: new_document }.to_json

              rescue StandardError => e
                routing.halt 400, { message: e.message }.to_json
              end

              # GET api/v1/properties/[property_id]/documents
              # Gets the list of documents related with a property
              routing.get do
                documents = Document.where(property_id:).all
                documents ? documents.to_json : raise('Document not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end
            end

            # DELETE api/v1/properties/[property_id]/delete
            # Deleted an existing property and the documents related with
            routing.on 'delete' do
              routing.post do
                raise('Could not delete property') unless Property.where(id: property_id).delete

                response.status = 200
                response['Location'] = "#{@properties_route}/#{property_id}/delete"
                { message: 'Property has been deleted' }.to_json
              end
            end

            # GET api/v1/properties/[property_id]
            # Get a specific property record
            routing.get do
              property = Property.first(id: property_id)
              raise NotFoundException if property.nil?

              property.to_json
            end

            # POST api/v1/properties/[property_id]
            # Updates an existing property
            routing.post do
              updated_data = JSON.parse(routing.body.read)
              updated_data['updated_at'] = Time.now.to_s
              update_result = Property.where(id: property_id).update(updated_data)
              raise NotFoundException if update_result.zero?

              response.status = 200
              response['Location'] = "#{@properties_route}/#{property_id}"
              { message: 'Property is updated', data: updated_data }.to_json
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

          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end

          # GET api/v1/properties
          # Gets the list of properties
          routing.get do
            output = { data: Property.all }
            JSON.pretty_generate(output)
          rescue StandardError
            raise NotFoundException('Could not find properties')
          end
        end

      rescue NotFoundException, PreConditionRequireException, BadRequestException, JSON::ParserError => e
        status_code = e.instance_variable_get(:@status_code)
        routing.halt status_code, { code: status_code, message: "Error: #{e.message}" }.to_json

      rescue StandardError => e
        status_code = 500
        routing.halt status_code, { code: status_code, message: "Error: #{e.message}" }.to_json
      end
    end
  end
end
