# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a properties
    class Property
      def initialize(requester:, property_owner_id:, property_owner_executor_id:)
        @requester = requester
        @property_owner_id = property_owner_id
        @property_owner_executor_id = property_owner_executor_id
      end

      def can_create?
        property_owner?
      end

      def can_update?
        property_owner?
      end

      def can_view?
        property_owner? || property_executor?
      end

      def can_delete?
        property_owner?
      end

      def summary
        {
          can_create: can_create?,
          can_view: can_view?,
          can_update: can_update?,
          can_delete: can_delete?
        }
      end

      private

      def property_owner?
        @property_owner_id.nil? ? false : @requester['id'] == @property_owner_id
      end

      def property_executor?
        @property_owner_executor_id.nil? ? false : @requester['id'] == @property_owner_executor_id
      end
    end
  end
end
