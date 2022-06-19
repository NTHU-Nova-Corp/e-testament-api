# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Relation Handling' do
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

    # setup data
    @executor_data = DATA[:accounts][0]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @executor = @accounts.next

    # setup login account
    login_account(@executor_data)
  end

  describe 'GET /api/v1/relations :: get relation list' do
    it 'HAPPY: should be able to get relation list' do
      # when
      get '/api/v1/relations'

      # then
      _(last_response.status).must_equal 200
      data = JSON.parse(last_response.body)['data']
      _(data.length).must_equal 17
    end
  end
end
