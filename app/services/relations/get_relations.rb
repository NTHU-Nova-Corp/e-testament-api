# frozen_string_literal: true

module ETestament
  module Services
    module Relations
      # Service object to create a new property for an account
      class GetRelations
        def self.call
          Relation.all
        end
      end
    end
  end
end
