# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class Heir
      def initialize(requester:, heir_owner_id:, heir_owner_executor_id:)
        @requester = requester
        @heir_owner_id = heir_owner_id
        @heir_owner_executor_id = heir_owner_executor_id
      end

      def can_create?
        heir_owner?
      end

      def can_update?
        heir_owner?
      end

      def can_view?
        heir_owner? || heir_executor?
      end

      def can_delete?
        heir_owner?
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

      def heir_owner?
        @heir_owner_id.nil? ? false : @requester['id'] == @heir_owner_id
      end

      def heir_executor?
        @heir_owner_executor_id.nil? ? false : @requester['id'] == @heir_owner_executor_id
      end
    end
  end
end
