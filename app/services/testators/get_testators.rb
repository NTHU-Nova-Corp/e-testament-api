# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      class GetTestators
        def self.call(id:)
          testators = Account.first(id:).testators
          testators.nil? ? [] : testators
        end
      end
    end
  end
end
