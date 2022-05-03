# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'There is no sunrise at the end of the universe'
    digest = ETestament::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'I think this password is very secure'
    digest_s = ETestament::Password.digest(password).to_s

    digest = ETestament::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'No one should be able to break my password!'
    password2 = 'Ima leave the door open'
    digest_s1 = ETestament::Password.digest(password1).to_s

    digest1 = ETestament::Password.from_digest(digest_s1)
    _(digest1.correct?(password2)).must_equal false
  end
end
