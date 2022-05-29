# frozen_string_literal: true

module ETestament

  module Policies
    # Policy to determine if account can view a project
    class Account
      def initialize(requester, account)
        @requester = requester
        @account = account
      end

      def can_view?
        self_request?
      end

      def can_edit?
        self_request?
      end

      def can_delete?
        self_request?
      end

      def summary
        {
          can_view: can_view?,
          can_edit: can_edit?,
          can_delete: can_delete?
        }
      end

      private

      def self_request?
        @requester['id'] == @account[:id]
      end
    end
  end
end
