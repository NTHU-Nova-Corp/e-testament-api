# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, properties sub-route
  class Api < Roda
    route('relations') do |routing|
      @account_id = 'ABC' # TODO: This will came from the headers in the api
      # Web controller for ETestament API, heirs sub-route
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
      end

      # TODO: GET api/v1/relations
      routing.get do
        # Heir.where(:account_id)
      end
    end
  end
end
