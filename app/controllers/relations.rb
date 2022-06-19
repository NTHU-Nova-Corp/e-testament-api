# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('relations') do |routing|
      # Web controller for ETestament API, heirs sub-route
      @relations_route = "#{@api_root}/relations"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      # GET api/v1/relations
      # Get all relations
      routing.get do
        output = Services::Relations::GetRelations.call
        { data: output }.to_json
      end
    end
  end
end
