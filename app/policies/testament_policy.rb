# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class Testament
      def initialize(requester:, owner_id:, executor_id:, previous_status:)
        @requester = requester
        @owner_id = owner_id
        @executor_id = executor_id
        @previous_status = previous_status
      end

      def can_complete?
        self_request? && under_edition?
      end

      def can_set_under_edition?
        self_request? && completed?
      end

      def can_release?
        executor_request? && completed?
      end

      def can_read?
        executor_request? && released?
      end

      def summary
        {
          can_complete: can_complete?,
          can_set_under_edition: can_set_under_edition?,
          can_release: can_release?,
          can_read: can_read?
        }
      end

      private

      def self_request?
        @requester['id'] == @owner_id
      end

      def executor_request?
        @requester['id'] == @executor_id
      end

      def under_edition?
        @previous_status == 'Under Edition'
      end

      def completed?
        @previous_status == 'Completed'
      end

      def released?
        @previous_status == 'Released'
      end
    end
  end
end
