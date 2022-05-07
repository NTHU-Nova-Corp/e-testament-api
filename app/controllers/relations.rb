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

      routing.on String do |_relation_id|
        # TODO: POST api/v1/relations/[relation_id]/delete
        # TODO Should not enable to delete if there is any property related with
        routing.post 'delete' do
        end

        # TODO: POST api/v1/relations/[relation_id]/edit
        routing.post 'edit' do
        end

        # TODO: POST api/v1/relations/[relation_id]
        routing.post do
        end

        # TODO: GET api/v1/relations/[relation_id]
        routing.get do
        end
      end

      # TODO: POST api/v1/relations
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_relation = Relation.new(new_data)
        raise BadRequestException, 'Could not save relation' unless new_relation.save

        response.status = 201
        response['Location'] = "#{@properties_route}/#{new_relation.id}"
        { message: 'Relation saved', data: new_relation }.to_json
      end

      # TODO: GET api/v1/relations
      routing.get do
        # Heir.where(:account_id)
      end
    end
  end
end
