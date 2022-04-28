# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:heirs) do
      uuid :id, primary_key: true
      foreign_key :account_id, table: :accounts, type: :uuid
      foreign_key :relation_id, table: :relations, type: Integer

      String :name, null: false
      String :email, null: false, unique: true

      DateTime :created_at
    end
  end
end
