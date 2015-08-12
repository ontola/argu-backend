require 'test_helper'

class UserTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:user) }

  def user
    @user ||= users(:user)
  end

  def test_valid
    assert user.valid?, user.errors.to_a.join(',').to_s
  end

  subject { FactoryGirl.create(:user_with_notification) }

  test 'should sync notification count' do
    assert_equal 0, notification_count(subject)
    subject.sync_notification_count
    assert_equal 1, notification_count(subject)
  end

  def notification_count(user)
    Redis.new.get("user:#{user.id}:notification.count").to_i
  end
end
