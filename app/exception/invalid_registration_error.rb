# frozen_string_literal: true

module ETestament
  module Exceptions
    # Invalid Registration Exception
    class InvalidRegistrationError < StandardError
      def initialize(msg = 'Invalid registration', exception_type = 'custom')
        @exception_type = exception_type
        super(msg)
      end
    end
  end
end
