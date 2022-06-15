# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if requester can view a project
    class Document
      def initialize(requester:, testament_status:, property_owner_id:, property_owner_executor_id:)
        @requester = requester
        @testament_status = testament_status
        @property_owner_id = property_owner_id
        @property_owner_executor_id = property_owner_executor_id
      end

      def can_create?
        property_owner? && testament_under_edition?
      end

      def can_view?
        property_owner? || (property_executor? && testament_read?)
      end

      def can_edit?
        property_owner? && testament_under_edition?
      end

      def can_delete?
        property_owner? && testament_under_edition?
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

      def property_executor?
        @property_owner_executor_id.nil? ? false : @requester['id'] == @property_owner_executor_id
      end

      def testament_read?
        @testament_status == 'Read'
      end

      def testament_under_edition?
        @testament_status == 'Under Edition'
      end
    end
  end
end
