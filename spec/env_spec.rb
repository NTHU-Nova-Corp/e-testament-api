# frozen_string_literal: true

require_relative './spec_helper'

describe 'Secret credentials not exposed' do
  it 'should not find database url' do
    assert_nil ETestament::Api.config.DATABASE_URL
  end
end
