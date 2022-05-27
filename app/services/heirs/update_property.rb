# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class AddPropertyHeir
        def self.call(new_data:)
          result = PropertyHeir.new(new_data)
          raise Exceptions::BadRequestError, 'Could not associate the property with the heir' unless result.save
        end
      end
    end
  end
end
