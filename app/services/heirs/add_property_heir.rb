# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class UpdateHeir
        def self.call(id:, updated_data:)
          heir = Heir.first(id:)
          raise Exceptions::NotFoundError if heir.nil?

          raise(updated_data.keys.to_s) unless heir.update(updated_data)
        end
      end
    end
  end
end
