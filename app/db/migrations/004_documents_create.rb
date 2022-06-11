# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:documents) do
      uuid :id, primary_key: true
      foreign_key :property_id, table: :properties, type: :uuid, null: false

      String :file_name, null: false
      String :description_secure
      String :content_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:property_id, :file_name]
    end
  end
end
