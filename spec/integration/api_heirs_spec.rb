# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Heir Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    seed_accounts
    seed_heirs
  end

  it 'HAPPY: should be able to get list of all heirs' do
    account = ETestament::Account.first

    # post '/api/v1/properties/122', new_property.to_json, req_header

    get 'api/v1/heirs', nil, { 'account_id' => account.id }
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 1
  end

  it 'HAPPY: should be able to get details of a single heir' do
    account = ETestament::Account.first

    existing_heir = account.heirs.first

    get "/api/v1/heirs/#{existing_heir.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal existing_heir.id
    _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
  end
end