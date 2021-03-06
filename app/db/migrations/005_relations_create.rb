# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:relations) do
      uuid :id, primary_key: true

      String :name, unique: true, null: false
      String :description, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
