# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Executors Handling' do
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
    @testator_data = DATA[:accounts][0]
    @executor_data = DATA[:accounts][1]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @testator = @accounts.next
    @executor = @accounts.next

    # setup login account
    login_account(@testator_data)
  end

  describe 'GET api/v1/executors' do
    it 'BAD: should not found executor' do
      # when
      get '/api/v1/executors'

      # then
      assert_nil JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 200
    end

    it 'should be able to get executor' do
      # given

      @testator.update(executor_id: @executor.id)

      # when
      get '/api/v1/executors'

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

  describe 'POST api/v1/executors' do
    it 'BAD: should not be able to assign the auth account as an executor' do
      # given
      accounts = ETestament::Account.first

      # when
      post 'api/v1/executors', { email: accounts[:email] }.to_json, @req_header

      # then
      _(last_response.status).must_equal 400
    end

    it 'HAPPY: should be able to assign the other account as an executor' do
      # when
      pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      # then
      assert_nil pending_executor_account

      # when
      post 'api/v1/executors', { email: @executor[:email] }.to_json, @req_header

      # then
      _(last_response.status).must_equal 200

      # when
      pending_executor_account_result = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      # then
      _(pending_executor_account_result[:owner_account_id]).must_equal @testator[:id]
      _(pending_executor_account_result[:executor_account_id]).must_equal @executor[:id]
    end

    # it 'HAPPY: should be able to send email request to non-account email' do
    #   # given
    #   executor_email = 'test_executor_email@gmail.com'
    #
    #   # when
    #   pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email:)
    #
    #   # then
    #   assert_nil pending_executor_account
    #
    #   # when
    #   post 'api/v1/executors', {email: executor_email }.to_json, @req_header
    #
    #   # then
    #   _(last_response.status).must_equal 200
    #
    #   #  when
    #   pending_executor_account_result = ETestament::PendingExecutorAccount.first(executor_email:)
    #
    #   # then
    #   _(pending_executor_account_result[:owner_account_id]).must_equal @testator[:id]
    # end
  end

  describe 'GET api/v1/executors/sent' do
    before(:each) do
      assert_nil ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      login_account(@testator_data)
      post 'api/v1/executors', { email: @executor[:email] }.to_json, @req_header
    end

    it 'HAPPY: should be able to get pending list' do
      # given
      login_account(@testator_data)

      # when
      get 'api/v1/executors/sent'

      # then
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)

      executor = response['data']['attributes']
      _(executor['id']).must_equal @executor[:id]
      _(executor['username']).must_equal @executor[:username]
      _(executor['first_name']).must_equal @executor[:first_name]
      _(executor['last_name']).must_equal @executor[:last_name]
      _(executor['email']).must_equal @executor[:email]
    end
  end

  describe 'POST api/v1/executors/:executor_email/cancel' do
    it 'HAPPY: should be able to cancel executor request' do
      # given
      post 'api/v1/executors', { email: @executor[:email] }.to_json, @req_header
      pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])
      _(pending_executor_account[:executor_email]).must_equal @executor[:email]

      #  when
      post "api/v1/executors/#{@executor[:email]}/cancel", @req_header

      # then
      _(last_response.status).must_equal 200
      pending_executor_account = ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])
      assert_nil pending_executor_account
    end

    it 'BAD: should not be able to cancel non exist executor email' do
      # when
      post "api/v1/executors/#{@executor[:email]}/cancel", @req_header

      # then
      _(last_response.status).must_equal 404
    end
  end
  describe 'POST api/v1/executors/:executor_email/unassign' do
    it 'HAPPY: should be able to unassign executor request' do
      # given
      @testator.update(executor_id: @executor[:id])
      @testator.refresh
      _(@testator[:executor_id]).wont_be_nil

      #  when
      post "api/v1/executors/#{@executor[:email]}/unassign", @req_header

      # then
      _(last_response.status).must_equal 200
      @testator.refresh
      assert_nil @testator[:executor_id]
    end

    it 'BAD: should not be able to cancel non exist executor email' do
      # when
      post "api/v1/executors/#{@executor[:email]}/cancel", @req_header

      # then
      _(last_response.status).must_equal 404
    end
  end
end
