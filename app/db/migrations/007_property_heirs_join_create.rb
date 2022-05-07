# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:property_heirs) do
      uuid :id, primary_key: true
      foreign_key :property_id, table: :properties, type: :uuid, null: false
      foreign_key :heir_id, table: :heirs, type: :uuid, null: false

      BigDecimal :percentage, size: [10, 2], null: false

      DateTime :created_at
      DateTime :updated_at

      unique [:property_id, :heir_id]
    end
  end
end
