# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all properties' do
    
  end

  it 'HAPPY: should be able to get details of a single property' do
    
  end

  it 'SAD: should return error if unknown property requested' do
    
  end

  it 'HAPPY: should be able to create new property' do
    
  end

  it 'HAPPY: should be able to delete existing property' do
    
  end

  it 'SAD: should return 404 when try to delete a property that doesnt exists' do
    
  end

  it 'HAPPY: should be able to update existing property' do
    
  end

  it 'SAD: should return 404 when try to update a property that doesnt exists' do
    
  end
end