# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Heir Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    seed_accounts
    seed_properties
    seed_heirs
    seed_property_heirs

    @account_data = DATA[:accounts][0]
    @auth = ETestament::AuthenticateAccount.call(
      username: @account_data['username'],
      password: @account_data['password']
    )
  end

  it 'HAPPY: should be able to get list of all heirs' do
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get 'api/v1/heirs'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 1
  end

  it 'HAPPY: should be able to get list of heirs to a property' do
  end

  it 'HAPPY: should be able to get details of a single heir' do
    account = ETestament::Account.first

    existing_heir = account.heirs.first

    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get "/api/v1/heirs/#{existing_heir.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal existing_heir.id
    _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
  end

  it 'SAD: should fail when fetching a nonexistent heir or invalid id' do
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get '/api/v1/heirs/69420'
    _(last_response.status).must_equal 404
  end
end
