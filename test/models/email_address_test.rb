# frozen_string_literal: true

require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase
  define_page
  let(:user) { create(:user) }
  let(:email_address) { EmailAddress.new(user: user) }

  test 'with subdomain' do
    email_address.email = 'test@ex.ample.com'
    assert email_address.valid?
  end

  test 'without second level domain' do
    email_address.email = 'test@example'
    assert_not email_address.valid?
  end

  test 'with special character' do
    email_address.email = 'tëst@example.nl'
    assert_not email_address.valid?
  end

  test 'should not set secondary email to primary on creation' do
    new_email = user.email_addresses.new(email: 'test@example.com', primary: true)
    assert_not new_email.valid?
  end

  test 'should set secondary email to primary on update' do
    create_email_mock(
      'confirm_secondary',
      user.email,
      token_url: /.+/,
      email: 'test@example.com'
    )

    original_email = user.primary_email_record
    assert original_email.reload.primary?
    new_email = ActsAsTenant.with_tenant(argu) { user.email_addresses.create(email: 'test@example.com') }
    assert_email_sent

    user.send(:set_reset_password_token)
    assert_not_nil user.reload.reset_password_token
    new_email.update(primary: true)
    assert new_email.reload.primary?
    assert_not original_email.reload.primary?
    assert_nil user.reload.reset_password_token
  end
end
