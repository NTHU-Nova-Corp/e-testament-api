# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class PropertyHeir
      def initialize(requester:, heir_owner_id:, property_owner_id:, heir_owner_executor_id:, property_owner_executor_id:)
        @requester = requester
        @heir_owner_id = heir_owner_id
        @property_owner_id = property_owner_id
        @heir_owner_executor_id = heir_owner_executor_id
        @property_owner_executor_id = property_owner_executor_id
      end

      def can_create_association?
        heir_owner? && property_owner?
      end

      def can_view_properties_associated_to_heir?
        heir_owner? || heir_executor?
      end

      def can_view_heirs_associated_to_property?
        property_owner? || property_executor?
      end

      def can_remove_association?
        heir_owner? && property_owner?
      end

      def summary
        {
          can_create_association: can_create_association?,
          can_view_properties_associated_to_heir: can_view_properties_associated_to_heir?,
          can_view_heirs_associated_to_property: can_view_heirs_associated_to_property?,
          can_remove_association: can_remove_association?
        }
      end

      private

      def heir_owner?
        @heir_owner_id.nil? ? false : @requester['id'] == @heir_owner_id
      end

      def property_owner?
        @property_owner_id.nil? ? false : @requester['id'] == @property_owner_id
      end

      def heir_executor?
        @heir_owner_executor_id.nil? ? false : @requester['id'] == @heir_owner_executor_id
      end

      def property_executor?
        @property_owner_executor_id.nil? ? false : @requester['id'] == @property_owner_executor_id
      end
    end
  end
end
