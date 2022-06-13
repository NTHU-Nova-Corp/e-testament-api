# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to reject request for being an executor
      class GetTestator
        def self.call(id:, testator_id:)
          testator = Account.first(id:).testators.find { |t| t.id.eql?(testator_id) }

          raise Exceptions::NotFoundError, 'Not found associated testators' if testator.nil?

          testator
        end
      end
    end
  end
end
