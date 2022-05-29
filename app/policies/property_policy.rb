# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class Property
      def initialize(requester)
        @requester = requester[:requester]
        @property_owner_account = requester[:property_owner_account]
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

      def can_remove?
        property_owner?
      end

      def summary
        {
          can_create: can_create?,
          can_view: can_view?,
          can_update: can_update?,
          can_remove: can_remove?
        }
      end

      private

      def property_owner?
        @property_owner_account.nil? ? false : @requester['id'] == @property_owner_account[:id]
      end

      def property_executor?
        @property_owner_account.nil? ? false : @requester['id'] == @property_owner_account[:executor_id]
      end
    end
  end
end
