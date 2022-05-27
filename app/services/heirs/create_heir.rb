# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  module Services
    module Heirs
      # Create heir for account
      class CreateHeir
        def self.call(id:, new_data:)
          account = Account.first(id:)
          raise Exceptions::NotFoundError, 'Could not find account' if account.nil?

          new_heir = account.add_heir(new_data)

          raise Exceptions::BadRequestError, 'Could not save heir' unless new_heir.save

          new_heir
        end
      end
    end
  end
end
