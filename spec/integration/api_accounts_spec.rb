# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
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
    @testator_data = DATA[:accounts][0]
    @executor_data = DATA[:accounts][1]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @testator = @accounts.next
    @executor = @accounts.next

    # setup login account
    login_account(@testator_data)
  end

  describe 'GET /api/v1/accounts/:username :: Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      # when
      get "/api/v1/accounts/#{@testator_data['username']}"

      # then
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)['data']['attributes']

      _(attributes['username']).must_equal @testator_data['username']
      assert_nil attributes['password']
      assert_nil attributes['password_hash']
      assert_nil attributes['salt']
    end

    it 'BAD: should not be able to get details of an account with another account' do
      # when
      get "/api/v1/accounts/#{@executor_data['username']}"

      # then
      _(last_response.status).must_equal 403
    end
  end

  describe 'POST api/v1/accounts :: Account Creation' do
    before do
      # clear
      wipe_database

      # setup
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      # when
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(@account_data).to_json,
           @req_header

      # then
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = ETestament::Account.first(id: created['id'])

      _(created['username']).must_equal @account_data['username']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'SECURITY_MASS_ASSIGNMENT: should not create account with illegal attributes' do
      # given
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'

      # when
      post 'api/v1/accounts',
           SignedRequest.new(app.config).sign(bad_data).to_json,
           @req_header

      # then
      _(last_response.status).must_equal 400
      assert_nil last_response.header['Location']
    end

    it 'SECURITY_UNSIGNED_REQUEST: should not accept unsigned requests' do
      # when
      post 'api/v1/accounts', @account_data.to_json

      # then
      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
    end
  end
end
