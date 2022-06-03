# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class Heir
      def initialize(requester)
        @requester = requester[:requester]
        @heir_owner_account = requester[:heir_owner_account]
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
        @heir_owner_account.nil? ? false : @requester['id'] == @heir_owner_account[:id]
      end

      def heir_executor?
        @heir_owner_account.nil? ? false : @requester['id'] == @heir_owner_account[:executor_id]
      end
    end
  end
end
