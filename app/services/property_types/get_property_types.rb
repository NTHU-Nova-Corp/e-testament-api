# frozen_string_literal: true

module ETestament
  module Services
    module PropertyType
      # Service object to create a new property for an account
      class GetPropertyTypes
        def self.call
          ETestament::PropertyType.all 
        end
      end
    end
  end
end
