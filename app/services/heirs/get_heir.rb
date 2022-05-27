# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetHeir
        def self.call(id:)
          heir = Heir.first(id:)
          raise Exceptions::NotFoundError if heir.nil?

          heir.to_json
        end
      end
    end
  end
end
