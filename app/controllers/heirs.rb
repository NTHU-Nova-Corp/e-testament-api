# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  @account_id = 'ABC' # TODO: This will came from the headers in the api
  # Web controller for ETestament API, heirs sub-route
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
    # Heir.where(:account_id)
  end
end
