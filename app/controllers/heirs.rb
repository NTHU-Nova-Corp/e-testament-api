# frozen_string_literal: true

require 'roda'
require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    # Web controller for ETestament API, heirs sub-route
    route('heirs') do |routing|
      @account_id = 'ABC' # TODO: This will came from the headers in the api
      @heirs_route = "#{@api_root}/heirs"

      routing.on String do |_heir_id|
        routing.on 'properties' do
          routing.on String do |_property_id|
            # TODO: POST api/v1/heirs/[heir_id]/properties/[property_id]/delete
            # TODO Should not enable to delete if there is any property related with
            routing.post 'delete' do
            end

            # TODO: POST api/v1/heirs/[heir_id]/properties/[property_id]/edit
            routing.post 'edit' do
            end

            # TODO: POST api/v1/heirs/[heir_id]/properties/[property_id]
            routing.post do
            end

            # TODO: GET api/v1/heirs/[heir_id]/properties/[property_id]
            routing.get do
            end
          end
          # TODO: POST api/v1/heirs/[heir_id]/properties
          routing.post do
          end

          # TODO: GET api/v1/heirs/[heir_id]/properties
          routing.get do
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
