# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  class CreatePropertyForAccount
    def self.call(id:, property:)
      Account.find(id:)
             .add_property(property)
    end
  end
end
