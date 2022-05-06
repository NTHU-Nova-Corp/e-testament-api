# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:property_heirs) do
      foreign_key :property_id, table: :properties, type: :uuid
      foreign_key :heir_id, table: :heirs, type: :uuid
      primary_key [:property_id, :heir_id]

      BigDecimal :percentage, size: [10, 2], null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
