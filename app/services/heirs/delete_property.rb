# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class DeleteProperty
        def self.call(property_id:, heir_id:)
          raise('Could not disasociate heir from property') unless PropertyHeir.where(property_id:,
                                                                                      heir_id:).delete

        end
      end
    end
  end
end
