# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to reject request for being an executor
      class GetTestators
        def self.call(id:)
          testators = Account.first(id:).testators

          raise Exceptions::NotFoundError, 'Not found associated testators' if testators.nil?

          testators
        end
      end
    end
  end
end
