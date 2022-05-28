# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class CreateProperty
        def self.call(account_id:, new_data:)
          account = Account.first(id: account_id)
          new_property = account.add_property(new_data)
          raise Exceptions::BadRequestError, 'Could not save property' unless new_property.save

          new_property
        end
      end
    end
  end
end
