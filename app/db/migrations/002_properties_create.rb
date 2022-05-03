# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:properties) do
      uuid :id, primary_key: true
      foreign_key :account_id, table: :accounts, type: :uuid

      String :name, unique: true, null: false
      String :description, unique: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:account_id, :name]
    end
  end
end
