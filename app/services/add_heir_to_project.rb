# frozen_string_literal: true

module ETestament
    # Add a heir to another owner's existing property
    class AddHeirToProperty
      # Error for owner cannot be heir
      class OwnerNotHeirError < StandardError
        def message = 'The heir cannot be the owner of a property'
      end
  
      def self.call(email:, property_id:)
        heir = Heir.first(email:)
        property = Property.first(id: property_id)
        raise(OwnerNotHeirError) if property.owner.id == heir.id
  
        property.add_heir(heir)
      end
    end
  end
end