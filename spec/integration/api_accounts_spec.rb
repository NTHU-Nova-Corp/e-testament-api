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

    # setup data
    @testor_data = DATA[:accounts][0]
    @executor_data = DATA[:accounts][1]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @testor = @accounts.next
    @executor = @accounts.next

    # setup login account
    login_account(@testor_data)
  end

  describe 'GET /api/v1/accounts/:username :: Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      get "/api/v1/accounts/#{@testor_data['username']}"
      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body)['data']['attributes']

      _(attributes['username']).must_equal @testor_data['username']
      assert_nil attributes['password']
      assert_nil attributes['password_hash']
      assert_nil attributes['salt']
    end

    it 'BAD: should not be able to get details of an account with another account' do
      get "/api/v1/accounts/#{@executor_data['username']}"
      _(last_response.status).must_equal 403
    end
  end

  describe 'POST api/v1/accounts :: Account Creation' do
    before do
      wipe_database

      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = ETestament::Account.first(id: created['id'])

      _(created['username']).must_equal @account_data['username']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'SECURITY: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      assert_nil last_response.header['Location']
    end
  end

  describe 'GET api/v1/accounts/executors' do
    it 'BAD: should not found executor' do
      get '/api/v1/accounts/executors'
      _(last_response.status).must_equal 404
    end

    it 'should be able to get executor' do
      # given

      @testor.update(executor_id: @executor.id)

      # when
      get '/api/v1/accounts/executors'

      # then
      _(last_response.status).must_equal 200
      attributes = JSON.parse(last_response.body)['data']['attributes']
      _(attributes['id']).must_equal @executor[:id]
      _(attributes['username']).must_equal @executor[:username]
      _(attributes['first_name']).must_equal @executor[:first_name]
      _(attributes['last_name']).must_equal @executor[:last_name]
      _(attributes['email']).must_equal @executor[:email]
    end
  end

  describe 'POST api/v1/accounts/executors' do
    it 'BAD: should not be able to assign the auth account as an executor' do
      # given
      accounts = ETestament::Account.first
      # when
      post 'api/v1/accounts/executors', { email: accounts[:email] }.to_json, @req_header
      # then
      _(last_response.status).must_equal 500
    end

    it 'HAPPY: should be able to assign the other account as an executor' do
      # when
      pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      # then
      assert_nil pending_executor_account

      # when
      post 'api/v1/accounts/executors', { email: @executor[:email] }.to_json, @req_header

      # then
      _(last_response.status).must_equal 200

      #  when
      pending_executor_account_result = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      # then
      _(pending_executor_account_result[:owner_account_id]).must_equal @testor[:id]
      _(pending_executor_account_result[:executor_account_id]).must_equal @executor[:id]
    end

    it 'HAPPY: should be able to send email request to non-account email' do
      # given
      executor_email = 'test_executor_email@gmail.com'

      # when
      pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email:)

      # then
      assert_nil pending_executor_account

      # when
      post 'api/v1/accounts/executors', { email: executor_email }.to_json, @req_header

      # then
      _(last_response.status).must_equal 200

      #  when
      pending_executor_account_result = ETestament::PendingExecutorAccount.first(executor_email:)

      # then
      _(pending_executor_account_result[:owner_account_id]).must_equal @testor[:id]
    end
  end

  describe 'Testor flow' do
    before(:each) do
      assert_nil ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      post 'api/v1/accounts/executors', { email: @executor[:email] }.to_json, @req_header
    end

    describe 'GET api/v1/accounts/testors/pending-requests' do
      it 'HAPPY: should be able to get pending list' do
        # given
        login_account(@executor_data)

        # when
        get 'api/v1/accounts/testors/pending-requests'
        _(last_response.status).must_equal 200

        response = JSON.parse(last_response.body)
        _(response['data'].length).must_equal 1

        testor = response['data'][0]['attributes']
        _(testor['owner_account_id']).must_equal @testor[:id]
      end
    end

    describe 'POST api/v1/accounts/testors/:testor_id/accept' do
      it 'HAPPY: should be able to accept' do
        # given
        login_account(@executor_data)

        # when then
        assert_nil @testor[:executor_id]
        _(ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])).wont_be_nil

        # when then
        post "api/v1/accounts/testors/#{@testor[:id]}/accept"
        _(last_response.status).must_equal 200

        @testor = ETestament::Account.first(email: @testor[:email])
        _(@testor[:executor_id]).must_equal @executor[:id]
        assert_nil ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])
      end
    end

    describe 'POST api/v1/accounts/testors/:testor_id/reject' do
      it 'HAPPY: should be able to reject' do
        # given
        login_account(@executor_data)

        # when then
        assert_nil @testor[:executor_id]
        _(ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])).wont_be_nil

        # when then
        post "api/v1/accounts/testors/#{@testor[:id]}/reject"
        _(last_response.status).must_equal 200
        assert_nil @testor[:executor_id]
        assert_nil ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])
      end
    end
  end
end
