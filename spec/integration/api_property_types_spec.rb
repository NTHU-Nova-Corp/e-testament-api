# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all property types' do
    ETestament::PropertyType.create(DATA[:property_types][1]).save
    ETestament::PropertyType.create(DATA[:property_types][2]).save
    get 'api/v1/property_types'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end
end
