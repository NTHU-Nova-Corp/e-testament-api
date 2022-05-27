# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to get the properties related with an an account
      class GetProperties
        def self.call(account_id:)
          account = Account.first(id: account_id)
          output = { data: account.properties }
          JSON.pretty_generate(output)
        end
      end
    end
  end
end
