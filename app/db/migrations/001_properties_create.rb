# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:properties) do
      uuid :id, primary_key: true

      String :name, unique: true, null: false
      String :description, unique: false, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
