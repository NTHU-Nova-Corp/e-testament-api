# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  module Services
    module Heirs
      # Create heir for account
      class DeleteHeirsFromProperty
        def self.call(heir_id:)
          raise('Could not delete heir') unless PropertyHeir.where(heir_id:).delete
          raise('Could not delete heir') unless Heir.where(id: heir_id).delete
        end
      end
    end
  end
end
