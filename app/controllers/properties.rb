# frozen_string_literal: true

require 'roda'
require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('properties') do |routing|
      @properties_route = "#{@account_route}/properties"

      routing.on String do |property_id|
        routing.on 'documents' do
          @documents_route = "#{@properties_route}/#{property_id}/documents"

          routing.on String do |document_id|
            # DELETE api/v1/properties/[property_id]/documents/[document_id]
            # Deleted a document related with a property
            routing.post 'delete' do
              property = Property.where(id: property_id).first
              raise NotFoundException if property.nil?

              current_document = Document.where(id: document_id, property_id:).first
              raise NotFoundException if current_document.nil?
              raise('Could not delete document associated with property') unless current_document.delete

              response.status = 200
              response['Location'] = "#{@documents_route}/#{document_id}"
              { message: 'Document associated with property has been deleted' }.to_json
            end

            # GET api/v1/properties/[property_id]/documents/[document_id]
            # Gets an specific document related with a property
            routing.get do
              property = Property.where(id: property_id).first
              raise NotFoundException if property.nil?

              document = Document.first(id: document_id)
              raise NotFoundException if document.nil?

              document.to_json
            end

            # PUT api/v1/properties/[property_id]/documents/[document_id]
            # Updates a document related with a property
            routing.post do
              updated_data = JSON.parse(routing.body.read)
              property = Property.where(id: property_id).first
              raise NotFoundException if property.nil?

              document = Document.first(id: document_id)
              raise NotFoundException if document.nil?

              raise(updated_data.keys.to_s) unless document.update(updated_data)

              response.status = 200
              response['Location'] = "#{@documents_route}/#{document_id}"
              { message: 'Document is updated', data: updated_data }.to_json
            end
          end

          # GET api/v1/accounts/[account_id]/properties/[property_id]/documents
          # Gets the list of documents related with a property
          routing.get do
            documents = Property.where(id: property_id).first.documents
            raise NotFoundException, 'Document not found' if documents.nil?

            documents.to_json
          end

          # POST api/v1/accounts/[account_id]/properties/[property_id]/documents
          # Creates a new document related with a property
          routing.post do
            new_data = JSON.parse(routing.body.read)
            existing_property = Property.first(id: property_id)
            new_document = existing_property.add_document(new_data)
            raise BadRequestException, 'Could not save document' unless new_document.save

            response.status = 201
            response['Location'] = "#{@documents_route}/#{new_document.id}"
            { message: 'Property saved', data: new_document }.to_json
          end
        end

        # DELETE api/v1/properties/[property_id]/delete
        # Deleted an existing property and the documents related with
        routing.post 'delete' do
          raise('Could not delete property') unless Property.where(id: property_id).delete

          response.status = 200
          response['Location'] = "#{@properties_route}/#{property_id}"
          { message: 'Property has been deleted' }.to_json
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
          property = Property.first(id: property_id)
          raise NotFoundException if property.nil?

          raise(updated_data.keys.to_s) unless property.update(updated_data)

          response.status = 200
          response['Location'] = "#{@properties_route}/#{property_id}"
          { message: 'Property is updated', data: updated_data }.to_json
        end
      end

      # GET api/v1/properties
      # Gets the list of properties
      routing.get do
        output = { data: ETestament::Property.all }
        JSON.pretty_generate(output)
      rescue StandardError
        raise NotFoundException('Could not find properties')
      end

      # POST api/v1/properties
      # Creates a new property
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_property = Property.new(new_data)
        raise BadRequestException, 'Could not save property' unless new_property.save

        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_property.id}"
        { message: 'Property saved', data: new_property }.to_json
      rescue StandardError => _e
        routing.halt 400, { message: 'Could not save property' }.to_json
      end
    
    rescue NotFoundException, PreConditionRequireException, BadRequestException, UnauthorizedException,
           JSON::ParserError => e
      status_code = e.instance_variable_get(:@status_code)
      routing.halt status_code, { code: status_code, message: "Error: #{e.message}" }.to_json
    rescue Sequel::MassAssignmentRestriction => e
      Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
      routing.halt 400, { message: 'Illegal Attributes' }.to_json
    rescue StandardError => e
      status_code = 500
      Api.logger.error "UNKOWN ERROR: #{e.message}"
      routing.halt status_code, { code: status_code, message: 'Error: Unknown server error' }.to_json
    end
    # rubocop:enable Metrics/BlockLength
  end
end