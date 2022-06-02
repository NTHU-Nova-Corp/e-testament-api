# frozen_string_literal: true

require 'roda'
require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    plugin :request_headers

    route('properties') do |routing|
      @properties_route = "#{@account_route}/properties"

      routing.on String do |property_id|
        @property = Property.first(id: property_id)
        raise Exceptions::NotFoundError, 'Property not found' if @property.nil?

        routing.on 'documents' do
          @documents_route = "#{@properties_route}/#{property_id}/documents"

          routing.on String do |document_id|
            @document = Document.first(id: document_id)
            raise Exceptions::NotFoundError, 'Property not found' if @document.nil?

            # DELETE api/v1/properties/:property_id/documents/:document_id
            # Deleted a document related with a property
            routing.post 'delete' do
              Services::Properties::DeleteDocument.call(property_id:, document_id:)
              response.status = 200
              response['Location'] = "#{@documents_route}/#{document_id}"
              { message: 'Document associated with property has been deleted' }.to_json
            end

            # GET api/v1/properties/:property_id/documents/:document_id
            # Gets an specific document related with a property
            routing.get do
              Services::Properties::GetDocument.call(property_id:, document_id:)
            end

            # PUT api/v1/properties/:property_id/documents/:document_id
            # Updates a document related with a property
            routing.post do
              updated_data = JSON.parse(routing.body.read)
              Services::Properties::UpdateDocument.call(updated_data:, property_id:, document_id:)

              response.status = 200
              response['Location'] = "#{@documents_route}/#{document_id}"
              { message: 'Document is updated', data: updated_data }.to_json
            end
          end

          # GET api/v1/properties/:property_id/documents
          # Gets the list of documents related with a property
          routing.get do
            Services::Properties::GetDocuments.call(property_id:)
          end

          # POST api/v1/properties/:property_id/documents
          # Creates a new document related with a property
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_document = Services::Properties::CreateDocument.call(property_id:, new_data:)
            response.status = 201
            response['Location'] = "#{@documents_route}/#{new_document.id}"
            { message: 'Property saved', data: new_document }.to_json
          end
        end

        routing.on 'heirs' do
          @heirs_route = "#{@properties_route}/#{property_id}/heirs"
          routing.on String do |heir_id|
            @heir = Heir.first(id: heir_id)
            raise Exceptions::NotFoundError, 'Heir does not found' if @heir.nil?

            # POST api/v1/properties/:property_id/heirs/:heir_id
            # Associate a heir to a property
            # TODO: unit-test
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_heir = Services::PropertyHeirs::AssociatePropertyHeir.call(requester: @auth_account, heir_data: @heir,
                                                                             property_data: @property, new_data:)

              response.status = 201
              response['Location'] = "#{@heirs_route}/#{new_heir.id}"
              { message: 'Heir saved', data: new_heir }.to_json
            end

            # POST api/v1/properties/:property_id/heirs/:heir_id/delete
            # Disassociate a heir to a property
            # TODO: unit-test
            # TODO: Delete pending to be implemented
            routing.post do
              response.status = 200
            end
          end

          # GET api/v1/properties/:property_id/heirs
          # Get a list of heirs associated with a property
          # TODO: unit-test
          routing.get do
            Services::PropertyHeirs::GetAssociatedHeirs.call(property_id:)
          end
        end

        # DELETE api/v1/properties/:property_id/delete
        # Deleted an existing property and the documents related with
        routing.post 'delete' do
          Services::Properties::DeleteProperty.call(property_id:)
          response.status = 200
          response['Location'] = "#{@properties_route}/#{property_id}"
          { message: 'Property has been deleted' }.to_json
        end

        # GET api/v1/properties/:property_id
        # Get a specific property record
        routing.get do
          Services::Properties::GetProperty.call(property_id:)
        end

        # POST api/v1/properties/:property_id
        # Updates an existing property
        routing.post do
          updated_data = JSON.parse(routing.body.read)
          Services::Properties::UpdateProperty.call(property_id:, updated_data:)
          response.status = 200
          response['Location'] = "#{@properties_route}/#{property_id}"
          { message: 'Property is updated', data: updated_data }.to_json
        end
      end

      # GET api/v1/properties/
      # Gets the list of properties
      routing.get do
        Services::Properties::GetProperties.call(account_id: @auth_account['id'])
      rescue StandardError
        raise Exceptions::ForbiddenError, 'Could not find any properties'
      end

      # POST api/v1/properties
      # Creates a new property
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_property = Services::Properties::CreateProperty.call(account_id: @auth_account['id'], new_data:)

        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_property.id}"
        { message: 'Property saved', data: new_property }.to_json
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end
