# frozen_string_literal: true

require 'roda'
require 'json'

# require_relative '../lib/key_stretch'
require_relative './helpers'
require_relative '../exception/bad_request_exception'
require_relative '../exception/unauthorized_exception'
require_relative '../exception/forbidden_exception'
require_relative '../exception/not_found_exception'
require_relative '../exception/pre_condition_required_exception'

# General ETestament module
module ETestament
  # Web controller for ETestament API
  class Api < Roda
    # plugin :environments
    plugin :halt
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
        end
      end
    end
  end
end
