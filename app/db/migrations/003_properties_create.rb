# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:properties) do
      uuid :id, primary_key: true
      foreign_key :account_id, table: :accounts, type: :uuid, null: false
      foreign_key :property_type_id, table: :property_types, type: :uuid, null: false

      String :name, null: false
      String :description, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:account_id, :name]
    end
  end
end
