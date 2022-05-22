# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:account_executor_pending) do
      uuid :id, primary_key: true
      foreign_key :account_owner_id, table: :accounts, type: :uuid, null: false
      foreign_key :account_executor_id, table: :accounts, type: :uuid, null: false

      String :executor_email, null: false, unique: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
