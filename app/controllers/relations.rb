# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('relations') do |routing|
      # Web controller for ETestament API, heirs sub-route
      # TODO: Fix it
      @account_id = routing.headers['account_id'] || routing.headers.instance_variable_get(:@env)['account_id']
      @heirs_route = "#{@api_root}/relations"

      # POST api/v1/relations
      # Create new relations
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_relation = Relation.new(new_data)
        raise BadRequestException, 'Could not save relation' unless new_relation.save

        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_relation.id}"
        { message: 'Relation saved', data: new_relation }.to_json
      end

      # GET api/v1/relations
      # Get all relations
      routing.get do
        output = { data: ETestament::Relation.all }
        JSON.pretty_generate(output)
      end
    end
  end
end
