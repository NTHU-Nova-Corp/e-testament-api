# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetHeirs
        def self.call(account_id:)
          output = { data: Heir.where(account_id:).all }
          JSON.pretty_generate(output)
        end
      end
    end
  end
end
