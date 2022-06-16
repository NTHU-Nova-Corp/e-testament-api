# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test SecureDB Class' do
  def helper(&)
    [[6, 3], [10, 2], [3, 2], [100, 30]].each(&)
  end

  shamir = ShamirEncryption::ShamirSecretSharing
  it 'HAPPY: it should be able to generate with the same available and needed number' do
    secret = 'hello'
    shares = shamir::Base64.split(secret, 3, 2)
    assert_equal secret, shamir::Base64.combine(shares.sample(3 * 2))
  end

  it 'HAPPY: test_shamir_base64 with multiple variable' do
    secret = 'hello'
    helper do |available, needed|
      shares = shamir::Base64.split(secret, available, needed)
      assert_equal secret, shamir::Base64.combine(shares.sample(available * needed))
    end
  end
end
