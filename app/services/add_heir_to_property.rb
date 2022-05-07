# frozen_string_literal: true

module ETestament
  # Add a heir to another owner's existing property
  class AddHeirToProperty
    # Error for owner cannot be heir
    class OwnerNotHeirError < StandardError
      def message = 'The heir cannot be the owner of a property'
    end

    def self.call(heir_id:, property_id:, property_heir:)
      property_heir = PropertyHeir.new(property_heir)
      property_heir.heir_id = heir_id
      property_heir.property_id = property_id
      property_heir.save
    end
  end
end
