# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      # TODO: Handle error
      class GetExecutorAccount
        def self.call(id:)
          pending = Account.first(id:).executors_pending
          { data: pending }
        end
      end
    end
  end
end



