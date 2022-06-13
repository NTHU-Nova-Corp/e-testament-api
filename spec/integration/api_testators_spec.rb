# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Testators Handling' do
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
    seed_heirs

    assign_executors

    # setup data
    @executor_data = DATA[:accounts][0]
    @testator1_data = DATA[:accounts][1]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @executor = @accounts.next
    @testator1 = @accounts.next

    # setup login account
    login_account(@executor_data)
  end

  describe 'GET /api/v1/testators :: testators of an executor' do
    it 'should be able to get testators' do
      # when
      get '/api/v1/testators'

      # then
      _(last_response.status).must_equal 200
      data = JSON.parse(last_response.body)['data']
      _(data.length).must_equal 2

      attributes = data[0]['attributes']
      _(attributes['id']).must_equal @testator1[:id]
      _(attributes['username']).must_equal @testator1[:username]
      _(attributes['first_name']).must_equal @testator1[:first_name]
      _(attributes['last_name']).must_equal @testator1[:last_name]
      _(attributes['email']).must_equal @testator1[:email]
    end
  end

  describe 'GET /api/v1/testators/:testator_id :: testator information' do
    it 'should be able to get testator information' do
      # when
      get "/api/v1/testators/#{@testator1[:id]}"

      # then
      _(last_response.status).must_equal 200
      attributes = JSON.parse(last_response.body)['data']['attributes']
      _(attributes['id']).must_equal @testator1[:id]
      _(attributes['username']).must_equal @testator1[:username]
      _(attributes['first_name']).must_equal @testator1[:first_name]
      _(attributes['last_name']).must_equal @testator1[:last_name]
      _(attributes['email']).must_equal @testator1[:email]
    end
  end

  describe 'GET /api/v1/testator/:testator_id/heirs :: heirs of a testator ' do
    it 'HAPPY: should be able to get heirs details of a testator' do
      # when
      get "/api/v1/testators/#{@testator1[:id]}/heirs"

      # then
      _(last_response.status).must_equal 200

      data = JSON.parse(last_response.body)['data']
      attributes = data[0]['attributes']

      _(attributes['first_name']).wont_be_nil
      _(attributes['last_name']).wont_be_nil
      _(attributes['email']).wont_be_nil
      _(attributes['relation']).wont_be_nil
    end

    it 'BAD: should not be able to get details of heir list from other executor' do
      login_account(@testator1_data)

      get "/api/v1/testators/#{@executor[:id]}/heirs"

      _(last_response.status).must_equal 403
    end
  end
end
