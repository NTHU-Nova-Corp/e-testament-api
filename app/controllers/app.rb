# frozen_string_literal: true

require 'roda'
require 'json'

# require_relative '../lib/key_stretch'
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
    plugin :multi_route

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL required.' }.to_json)

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
