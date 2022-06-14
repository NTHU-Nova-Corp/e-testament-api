# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a relations between properties and heirs
    class PropertyHeir
      # rubocop: disable Metrics/ParameterLists
      def initialize(requester:, testament_status:, heir_owner_id:, property_owner_id:,
                     heir_owner_executor_id:, property_owner_executor_id:)
        @requester = requester
        @heir_owner_id = heir_owner_id
        @property_owner_id = property_owner_id
        @heir_owner_executor_id = heir_owner_executor_id
        @property_owner_executor_id = property_owner_executor_id
        @testament_status = testament_status
      end
      # rubocop: enable Metrics/ParameterLists

      def can_create_association?
        heir_owner? && property_owner?
      end

      def can_view_associations_between_heirs_and_properties?
        property_owner? || heir_owner? || (testament_read? && (property_executor? || heir_executor?))
      end

      def can_delete_association?
        heir_owner? && property_owner?
      end

      def can_update_association?
        heir_owner? && property_owner?
      end

      def summary
        {
          can_create_association: can_create_association?,
          can_view_associations_between_heirs_and_properties: can_view_associations_between_heirs_and_properties?,
          can_delete_association: can_delete_association?,
          can_update_association: can_update_association?
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

      def testament_read?
        @testament_status == 'Read'
      end
    end
  end
end
