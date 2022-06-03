# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  def login_account(account)
    @account_data = account

    @auth = ETestament::Services::Accounts::Authenticate.call(
      username: @account_data['username'],
      password: @account_data['password']
    )
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
  end

  before(:each) do
    # clear
    wipe_database

    # seed
    seed_accounts
    seed_properties
    seed_heirs
    seed_property_heirs

    # setup data
    @owner_account_data = DATA[:accounts][0]
    @executor_account_data = DATA[:accounts][1]
    @other_account_data = DATA[:accounts][2]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @owner = @accounts.next
    @executor = @accounts.next
    @other = @accounts.next
    @owner.update(executor_id: @executor[:id])

    # setup login account
    login_account(@owner_account_data)
  end

  describe 'GET api/v1/property_types' do
    it 'HAPPY: should be able to get list of all property types' do
      get 'api/v1/property_types'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 10
    end
  end
end
