# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if requester can view a project
    class Document
      def initialize(requester, document_account_owner)
        @requester = requester
        @document_account_owner = document_account_owner
      end

      def can_view?
        owner? || executor?
      end

      def can_edit?
        owner?
      end

      def can_delete?
        owner?
      end

      def summary
        {
          can_view: can_view?,
          can_edit: can_edit?,
          can_delete: can_delete?
        }
      end

      private

      def owner?
        @requester['id'] == @document_account_owner[:id]
      end

      def executor?
        @requester['id'] == @document_account_owner[:executor_id]
      end
    end
  end
end
