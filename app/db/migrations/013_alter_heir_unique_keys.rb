# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:heirs) do
      add_unique_constraint([:account_id, :email], name: :account_email)
    end
  end
end
