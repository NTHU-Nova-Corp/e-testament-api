# frozen_string_literal: true

module ETestament
  module Exceptions
    # Bad request exception
    class BadRequestError < StandardError
      def initialize(msg = 'Bad request', exception_type = 'custom')
        @exception_type = exception_type
        @status_code = 400
        super(msg)
      end
    end
  end
end
