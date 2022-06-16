# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Validates and stores the key submitted
      class SubmitHeirKey
        def self.call(heir_id:, key_content_submitted:)
          heir = Heir.first(id: heir_id)

          raise Exceptions::BadRequestError, 'Not heir found' if heir.nil?
          raise Exceptions::BadRequestError, 'Wrong key sent' unless heir.individual_key?(key_content_submitted)

          heir.update(key_content_submitted:)
          heir
        end
      end
    end
  end
end
