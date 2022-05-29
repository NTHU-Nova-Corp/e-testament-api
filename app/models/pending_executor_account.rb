# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # PendingExecutorAccount model
  class PendingExecutorAccount < Sequel::Model
    many_to_one :owner_account, class: :'ETestament::Account', key: :owner_account_id
    many_to_one :executor_account, class: :'ETestament::Account', key: :executor_account_id

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :executor_email, :owner_account_id, :executor_account_id

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'pending_executor_account',
            attributes: {
              id:,
              owner_account_id:,
              executor_account_id:,
              executor_email:
            }
          }
        }, options
      )
    end

    # rubocop:enable Metrics/MethodLength
    def executor_account_id
      # code here
    end
  end
end
