# frozen_string_literal: true

module ETestament
  module Exceptions
    # Unauthorized exception
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        super
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:username]}"
      end
    end
  end
end
