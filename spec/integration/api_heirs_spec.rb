# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    seed_accounts
    seed_heirs
  end

  it 'HAPPY: should be able to get list of all heirs' do
    account = ETestament::Account.first
    heir0 = DATA[:heirs][0]
    heir1 = DATA[:heirs][1]
    account.add_heir(property0)
    account.add_heir(property1)

    get 'api/v1/heirs'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single heir' do
    account = ETestament::Account.first
    heir0 = DATA[:properties][0]
    account.add_heir(heir0)

    existing_heir = account.heirs.first

    get "/api/v1/heirs/#{existing_heir.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal existing_heir.id
    _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
  end
end