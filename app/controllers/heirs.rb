# frozen_string_literal: true

require 'roda'
require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    plugin :request_headers
    # Web controller for ETestament API, heirs sub-route
    route('heirs') do |routing|
      @account_id = routing.headers['account_id']
      @heirs_route = "#{@api_root}/heirs"

      routing.on String do |heir_id|
        routing.on 'properties' do
          routing.on String do |property_id|
            @heirs_property_route = "#{@heirs_route}/#{heir_id}/properties/#{property_id}"
            # TODO: POST api/v1/heirs/[heir_id]/properties/[property_id]/delete
            # TODO Should not enable to delete if there is any property related with
            routing.post 'delete' do
            end

            # TODO: POST api/v1/heirs/[heir_id]/properties/[property_id]
            routing.post do
              new_data = JSON.parse(routing.body.read)
              result = PropertyHeir.new(new_data)
              raise BadRequestException, 'Could not associate the property with the heir' unless result.save

              response.status = 201
              response['Location'] = @heirs_property_route.to_s
              { message: 'Property associated with the heir', data: result }.to_json
            end

            # TODO: GET api/v1/heirs/[heir_id]/properties/[property_id]
            routing.get do
              output = { data: ETestament::PropertyHeir.first(heir_id:, property_id:) }
              JSON.pretty_generate(output)
            end
          end

          # TODO: GET api/v1/heirs/[heir_id]/properties
          routing.get do
            output = { data: ETestament::PropertyHeir.all }
            JSON.pretty_generate(output)
          end
        end

        # TODO: POST api/v1/heirs/[heir_id]/delete
        # TODO Should not enable to delete if there is any property related with
        routing.post 'delete' do
        end

        # TODO: POST api/v1/heirs/[heir_id]/edit
        routing.post 'edit' do
        end

        # TODO: POST api/v1/heirs/[heir_id]
        routing.post do
        end

        # TODO: GET api/v1/heirs/[heir_id]
        routing.get do
        end
      end

      # TODO: POST api/v1/heirs
      routing.post do
        account = Account.first(id: @account_id)
        new_data = JSON.parse(routing.body.read)
        new_heir = account.add_heir(new_data)
        raise BadRequestException, 'Could not save heir' unless new_heir.save

        response.status = 201
        response['Location'] = "#{@heirs_route}/#{new_heir.id}"
        { message: 'Heir saved', data: new_heir }.to_json
      end

      # TODO: GET api/v1/heirs
      routing.get do
        output = { data: ETestament::Heir.all }
        JSON.pretty_generate(output)
      rescue StandardError
        raise NotFoundException('Could not find heirs')
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