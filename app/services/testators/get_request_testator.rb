# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to get pending request for being an executor
      class GetRequestTestator
        def self.call(id:)
          Account.first(id:).request_testators.first.testator_account
        end
      end
    end
  end
end
