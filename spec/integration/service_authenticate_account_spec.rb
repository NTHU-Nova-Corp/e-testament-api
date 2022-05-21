# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthenticateAccount service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      ETestament::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = ETestament::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      ETestament::AuthenticateAccount.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise ETestament::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      ETestament::AuthenticateAccount.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise ETestament::AuthenticateAccount::UnauthorizedError
  end
end