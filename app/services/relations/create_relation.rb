# frozen_string_literal: true

module ETestament
  module Services
    module Relations
      # Service object to create a new property for an account
      class CreateRelation
        def self.call(new_data:)
          new_relation = Relation.new(new_data)
          raise Exceptions::BadRequestError, 'Could not save relation' unless new_relation.save

          new_relation
        end
      end
    end
  end
end
