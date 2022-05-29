# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class PropertyHeir
      def initialize(requester)
        @requester = requester[:requester]
        @heir_owner_account = requester[:heir_owner_account]
        @property_owner_account = requester[:property_owner_account]
      end

      def can_create_association?
        heir_owner? && property_owner?
      end

      def can_view_heir_associations?
        heir_owner? || heir_executor?
      end

      def can_view_property_associations?
        property_owner? || property_executor?
      end

      def can_remove_association?
        heir_owner? && property_owner?
      end

      def summary
        {
          can_create_association: can_create_association?,
          can_view_heir_associations: can_view_heir_associations?,
          can_view_property_associations: can_view_property_associations?,
          can_remove_association: can_remove_association?
        }
      end

      private

      def heir_owner?
        @heir_owner_account.nil? ? false : @requester['id'] == @heir_owner_account[:id]
      end

      def property_owner?
        @property_owner_account.nil? ? false : @requester['id'] == @property_owner_account[:id]
      end

      def heir_executor?
        @heir_owner_account.nil? ? false : @requester['id'] == @heir_owner_account[:executor_id]
      end

      def property_executor?
        @property_owner_account.nil? ? false : @requester['id'] == @property_owner_account[:executor_id]
      end
    end
  end
end
