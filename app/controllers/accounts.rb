# frozen_string_literal: true

require_relative './app'

# General ETestament module
module ETestament
  # Web controller for ETestament API, accounts sub-route
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          account = Account.first(:username)
          raise NotFoundException, 'Account not found.' if account.nil?
          account.to_json
        end
      end

      routing.post do
        # POST api/v1/accounts
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise 'Could not save account' unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end