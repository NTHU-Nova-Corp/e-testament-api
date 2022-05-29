# frozen_string_literal: true

require 'roda'
require 'json'

# require_relative '../lib/key_stretch'
require_relative './helpers'

# General ETestament module
module ETestament
  # Web controller for ETestament API
  class Api < Roda
    # plugin :environments
    plugin :halt
    plugin :all_verbs
    plugin :multi_route
    plugin :request_headers
    plugin :default_headers, {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Headers' => '*',
      'Access-Control-Allow-Credentials' => 'true',
      'Accept' => '*/*'
    }

    include SecureRequestHelpers

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL required.' }.to_json)

      begin
        @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      rescue AuthToken::ExpiredTokenError
        routing.halt 403, { message: 'Expired auth token' }.to_json
      end

      # GET /
      routing.root do
        response.status = 200
        { message: 'ETestamentAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        rescue Sequel::MassAssignmentRestriction => e
          Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue Exceptions::NotFoundError, Exceptions::BadRequestError,
               Exceptions::ForbiddenError, JSON::ParserError => e
          status_code = e.instance_variable_get(:@status_code)
          routing.halt status_code, { code: status_code, message: "Error: #{e.message}" }.to_json
        rescue StandardError => e
          case e
          when Sequel::UniqueConstraintViolation
            status_code = 400
            error_message = e.wrapped_exception
            Api.logger.error e.message
          else
            error_message = 'Error : Unknown server error'
            status_code = 500
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
          end
          routing.halt status_code, { code: status_code, message: error_message }.to_json
        end
      end
    end
  end
end
