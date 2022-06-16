# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # PendingExecutorAccount model
  class PendingExecutorAccount < Sequel::Model
    many_to_one :testator_account, class: :'ETestament::Account', key: :owner_account_id
    many_to_one :executor_account, class: :'ETestament::Account', key: :executor_account_id

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :executor_email, :owner_account_id, :executor_account_id

    def to_h
      {
        type: 'pending_executor_account',
        attributes: {
          id:,
          owner_account_id:,
          executor_account_id:,
          executor_email:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner_account:,
          executor_account:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
