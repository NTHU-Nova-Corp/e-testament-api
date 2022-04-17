# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'
require 'json'

require_relative '../app/controllers/app'
require_relative '../app/models/property'

def app
  ETestament::Api
end

describe 'Test ETestament Web API' do
  include Rack::Test::Methods

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end
end
