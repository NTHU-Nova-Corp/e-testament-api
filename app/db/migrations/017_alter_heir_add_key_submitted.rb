# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:heirs) do
      add_column(:key_content_submitted_secure, String, null: false, default: '')
    end
  end
end
