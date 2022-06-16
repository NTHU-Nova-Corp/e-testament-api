# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Validates and stores the key submitted
      class SubmitHeirKey
        def self.call(heir_id:, key_content_submitted:)
          # TODO: Validate that the key store is the same as the one hashed and stored

          heir = Heir.first(id: heir_id)

          raise Exceptions::NotFoundError, 'Not heir found' if heir.nil?

          heir.update(key_content_submitted:)
          heir
        end
      end
    end
  end
end
