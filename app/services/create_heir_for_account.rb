# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  class CreateHeirForAccount
    def self.call(account_id:, heir:)
      Account.find(id: account_id)
             .add_heir(heir)
    end
  end
end
