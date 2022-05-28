# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Add a heir to another owner's existing property
      class AssociateHeir
        def self.call(heir_id:, property_id:, property_heir:)
          property_heir = PropertyHeir.new(property_heir)
          property_heir.heir_id = heir_id
          property_heir.property_id = property_id
          raise Exceptions::BadRequestError, 'Could not add heir' unless property_heir.save

          property_heir
        end
      end
    end
  end
end
