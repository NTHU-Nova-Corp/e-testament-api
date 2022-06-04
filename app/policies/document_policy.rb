# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if requester can view a project
    class Document
      def initialize(requester:, property_owner_id:)
        @requester = requester
        @property_owner_id = property_owner_id
      end

      def can_create?
        property_owner?
      end

      def can_view?
        property_owner?
      end

      def can_edit?
        property_owner?
      end

      def can_delete?
        property_owner?
      end

      def summary
        {
          can_view: can_view?,
          can_edit: can_edit?,
          can_delete: can_delete?
        }
      end

      private

      def property_owner?
        @requester['id'] == @property_owner_id
      end
    end
  end
end
