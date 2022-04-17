# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:documents) do
      uuid :id, primary_key: true
      foreign_key :property_id, table: :properties, type: :uuid

      String :file_name, null: false
      String :relative_path, null: false, default: ''
      String :description
      String :content, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:property_id, :file_name, :relative_path]
    end
  end
end
