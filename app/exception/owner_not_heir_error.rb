# frozen_string_literal: true

module ETestament
  module Exceptions
    # Owner Not Heir Error
    class OwnerNotHeirError < StandardError
      def message = 'The heir cannot be the owner of a property'
    end
  end
end
