# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:heirs) do
      uuid :id, primary_key: true
      foreign_key :account_id, table: :accounts, type: :uuid, null: false
      foreign_key :relation_id, table: :relations, type: :uuid, null: false

      String :first_name, null: false
      String :last_name, null: false
      String :password, null: false
      String :email, null: false, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
