# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to create a new property for an account
      class CreateProperty
        def self.call(account_id:, property:)
          Account.find(id: account_id)
                 .add_property(property)
        end
      end
    end
  end
end
