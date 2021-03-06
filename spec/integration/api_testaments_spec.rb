# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Testaments Handling' do
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

    @owner_data = DATA[:accounts][0]
    @accounts = ETestament::Account.all.cycle
    @owner = @accounts.next

    # setup login account
    login_account(@owner_data)
  end

  describe 'GET api/v1/testaments' do
    it 'HAPPY: should be able to view the testament details of its own account' do
      get 'api/v1/testaments', @req_header
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      _(response['data'].length).must_equal 2
    end
  end

  describe 'POST api/v1/testaments/complete' do
    it 'HAPPY: should be able to complete a testament details of its own account
    that has all the properties distributed' do
      @owner.properties.map do |property|
        property.property_heirs.map do |property_heir|
          property_heir.update(percentage: 100).save
        end
      end
      post 'api/v1/testaments/complete', { min_amount_heirs: 2 }.to_json, @req_header

      _(last_response.status).must_equal 200

      account_val = ETestament::Account.first
      _(account_val.testament_status).must_equal('Completed')
    end

    it 'BAD AUTHORIZATION: should not be able to complete a testament details of its own account that
      has all the properties distributed' do
      post 'api/v1/testaments/complete', { min_amount_heirs: 1 }.to_json, @req_header

      _(last_response.status).must_equal 400
    end
  end
end
