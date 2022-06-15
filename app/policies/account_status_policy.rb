# frozen_string_literal: true

module ETestament
  module Policies
    # Policy to determine if account can view a project
    class AccountStatus
      def initialize(requester:, owner_id:, executor_id:, previous_status:, new_status:)
        @requester = requester
        @owner_id = owner_id
        @executor_id = executor_id
        @previous_status = previous_status
        @new_status = new_status
      end

      def can_edit?
        self_request? || executor_request?
      end

      def summary
        {
          can_edit: can_edit?
        }
      end

      private

      def self_request?
        @requester['id'] == @owner_id &&
          (@previous_status == 'Completed' || @previous_status == 'Under Edition') &&
          (@new_status == 'Completed' || @new_status == 'Under Edition')
      end

      def executor_request?
        @requester['id'] == @executor_id &&
          (@previous_status == 'Completed' || @previous_status == 'Released') &&
          (@new_status == 'Completed' || @new_status == 'Read')
      end
    end
  end
end
