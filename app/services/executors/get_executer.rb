# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to get the Account Information
      # TODO: Handle error
      class GetExecutor
        def self.call(id:)
          Account.first(id:).executor
        end
      end
    end
  end
end
