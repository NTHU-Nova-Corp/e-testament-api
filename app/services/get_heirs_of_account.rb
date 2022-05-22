# frozen_string_literal: true

module ETestament
  # Service object to get the heirs related with an an account
  class GetHeirsOfAccount
    def self.call(account_id:)
      output = { data: ETestament::Heir.where(account_id:).all }
      JSON.pretty_generate(output)
    end
  end
end
