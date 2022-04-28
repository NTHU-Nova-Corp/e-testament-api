# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../lib/key_stretch'
require_relative '../exception/bad_request_exception'
require_relative '../exception/unauthorized_exception'
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
        routing.on 'accounts' do
          @accounts_route = "#{@api_root}/accounts"

          # POST api/v1/accounts/[account_id]/login
          # Sign in to the system
          routing.post 'login' do
            request = JSON.parse(routing.body.read)
            email = request['email']
            account = Account.where(email:).first
            raise NotFoundException, 'Email not found' if account.nil?

            password = request['password']
            actual_password_digest = ETestament::Password.from_digest(account.password_digest)

            response.status = 401
            raise UnauthorizedException, 'Password incorrect!' unless actual_password_digest.correct?(password)

            response.status = 200
            account.to_json
          end

          routing.on String do |account_id|
            @account_route = "#{@accounts_route}/#{account_id}"

            routing.on 'properties' do
              @properties_route = "#{@account_route}/properties"

              routing.on String do |property_id|
                @property_route = "#{@properties_route}/#{property_id}"

                routing.on 'documents' do
                  @documents_route = "#{@property_route}/documents"

                  routing.on String do |document_id|
                    @document_route = "#{@documents_route}/#{document_id}"

                    # DELETE api/v1/accounts/[account_id]/properties/[property_id]/documents/[document_id]
                    # Deleted a document related with a property
                    routing.post 'delete' do
                      property = Property.where(id: property_id, account_id:).first
                      raise NotFoundException if property.nil?

                      current_document = Document.where(id: document_id, property_id:).first
                      raise NotFoundException if current_document.nil?
                      raise('Could not delete document associated with property') unless current_document.delete

                      response.status = 200
                      response['Location'] = "#{@documents_route}/#{document_id}"
                      { message: 'Document associated with property has been deleted' }.to_json
                    end

                    # GET api/v1/accounts/[account_id]/properties/[property_id]/documents/[document_id]
                    # Gets an specific document related with a property
                    routing.get do
                      property = Property.where(id: property_id, account_id:).first
                      raise NotFoundException if property.nil?

                      document = Document.first(id: document_id, property_id:)
                      raise NotFoundException if document.nil?

                      document.to_json
                    end

                    # PUT api/v1/accounts/[account_id]/properties/[property_id]/documents/[document_id]
                    # Updates a document related with a property
                    routing.post do
                      updated_data = JSON.parse(routing.body.read)
                      property = Property.where(id: property_id, account_id:).first
                      raise NotFoundException if property.nil?

                      document = Document.first(id: document_id, property_id:)
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
                    documents = Property.where(id: property_id, account_id:).first.documents
                    raise NotFoundException, 'Document not found' if documents.nil?

                    documents.to_json
                  end

                  # POST api/v1/accounts/[account_id]/properties/[property_id]/documents
                  # Creates a new document related with a property
                  routing.post do
                    new_data = JSON.parse(routing.body.read)
                    existing_property = Property.first(id: property_id, account_id:)
                    new_document = existing_property.add_document(new_data)
                    raise BadRequestException, 'Could not save document' unless new_document.save

                    response.status = 201
                    response['Location'] = "#{@documents_route}/#{new_document.id}"
                    { message: 'Property saved', data: new_document }.to_json
                  end
                end

                # DELETE api/v1/accounts/[account_id]/properties/[property_id]/delete
                # Deleted an existing property and the documents related with
                routing.post 'delete' do
                  raise('Could not delete property') unless Property.where(id: property_id, account_id:).delete

                  response.status = 200
                  response['Location'] = "#{@properties_route}/#{property_id}"
                  { message: 'Property has been deleted' }.to_json
                end

                # GET api/v1/accounts/[account_id]/properties/[property_id]
                # Get a specific property record
                routing.get do
                  property = Property.first(id: property_id, account_id:)
                  raise NotFoundException if property.nil?

                  property.to_json
                end

                # POST api/v1/accounts/[account_id]/properties/[property_id]
                # Updates an existing property
                routing.post do
                  updated_data = JSON.parse(routing.body.read)
                  property = Property.first(id: property_id, account_id:)
                  raise NotFoundException if property.nil?

                  raise(updated_data.keys.to_s) unless property.update(updated_data)

                  response.status = 200
                  response['Location'] = "#{@properties_route}/#{property_id}"
                  { message: 'Property is updated', data: updated_data }.to_json
                end
              end

              # GET api/v1/accounts/[account_id]/properties
              # Gets the list of properties
              routing.get do
                output = { data: ETestament::Property.where(account_id:).all }
                JSON.pretty_generate(output)
              rescue StandardError
                raise NotFoundException('Could not find properties')
              end

              # POST api/v1/accounts/[account_id]/properties
              # Creates a new property
              routing.post do
                new_data = JSON.parse(routing.body.read)
                account = Account.first(id: account_id)
                new_property = account.add_property(new_data)
                # new_property = Property.new(new_data)
                raise BadRequestException, 'Could not save property' if new_property.nil?

                response.status = 201
                response['Location'] = "#{@properties_route}/#{new_property.id}"
                { message: 'Property saved', data: new_property }.to_json
              rescue StandardError => _e
                routing.halt 400, { message: 'Could not save property' }.to_json
              end
            end
          end

          # POST api/v1/accounts
          # Sign up new account
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = ETestament::Account.create(new_data)
            raise BadRequestException, 'Could not create account' if new_account.nil?

            response.status = 201
            response['Location'] = @accounts_route.to_s
            { message: 'Property saved', data: new_account }.to_json

          rescue StandardError => _e
            routing.halt 400, { message: 'Could not signup a new account' }.to_json
          end
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
    end
  end
end
