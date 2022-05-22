# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pending_executor_accounts) do
      uuid :id, primary_key: true
      foreign_key :owner_account_id, table: :accounts, type: :uuid, null: false
      foreign_key :executor_account_id, table: :accounts, type: :uuid, null: true

      String :executor_email, null: false, unique: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
