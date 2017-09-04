# frozen_string_literal: true

require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  let(:user) { create(:user) }

  test 'should not set secondary email to primary on creation' do
    new_email = user.emails.new(email: 'test@example.com', primary: true)
    assert_not new_email.valid?
  end

  test 'should set secondary email to primary on update' do
    original_email = user.primary_email_record
    assert original_email.reload.primary?
    new_email = user.emails.create(email: 'test@example.com')
    new_email.update(primary: true)
    assert new_email.reload.primary?
    assert_not original_email.reload.primary?
  end
end
