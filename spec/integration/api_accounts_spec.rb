# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Accounts Handling' do
  include Rack::Test::Methods
  req_header = { 'CONTENT_TYPE' => 'application/json' }

  before do
    wipe_database
  end

  describe 'api/v1/accounts/login' do
    it 'HAPPY: should be able to login' do
      existing_account = DATA[:accounts][0]
      ETestament::Account.create(existing_account)

      post '/api/v1/accounts/login', existing_account.to_json, req_header
      _(last_response.status).must_equal 200

      profile = JSON.parse(last_response.body)['data']['attributes']
      _(profile['first_name']).must_equal existing_account['first_name']
      _(profile['last_name']).must_equal existing_account['last_name']
      _(profile['email']).must_equal existing_account['email']
    end
    it 'SAD: should not be able to login with unexciting email' do
      existing_account = DATA[:accounts][0]

      post '/api/v1/accounts/login', existing_account.to_json, req_header
      _(last_response.status).must_equal 404
    end
    it 'SAD: should not be able to login with wrong password' do
      existing_account = DATA[:accounts][0]
      ETestament::Account.create(existing_account)
      existing_account['password'] = 'I love nutella'
      post '/api/v1/accounts/login', existing_account.to_json, req_header
      _(last_response.status).must_equal 401
    end
  end

  describe 'api/v1/accounts' do
    it 'HAPPY: should be able to signup' do
      new_account = DATA[:accounts][0]
      post '/api/v1/accounts', new_account.to_json, req_header
      _(last_response.status).must_equal 201

      profile = JSON.parse(last_response.body)['data']['data']['attributes']
      _(profile['first_name']).must_equal new_account['first_name']
      _(profile['last_name']).must_equal new_account['last_name']
      _(profile['email']).must_equal new_account['email']
    end

    it 'HAPPY: should not be able to signup and login' do
      new_account = DATA[:accounts][0]
      post '/api/v1/accounts', new_account.to_json, req_header
      _(last_response.status).must_equal 201

      post '/api/v1/accounts/login', new_account.to_json, req_header
      _(last_response.status).must_equal 200

      profile = JSON.parse(last_response.body)['data']['attributes']
      _(profile['first_name']).must_equal new_account['first_name']
      _(profile['last_name']).must_equal new_account['last_name']
      _(profile['email']).must_equal new_account['email']
    end

    it 'SAD: should not be able to signup with existing email' do
      new_account = DATA[:accounts][0]
      post '/api/v1/accounts', new_account.to_json, req_header
      _(last_response.status).must_equal 201

      post '/api/v1/accounts', new_account.to_json, req_header
      _(last_response.status).must_equal 400
    end
  end
end
