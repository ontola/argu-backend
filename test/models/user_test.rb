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

  test 'should greet with best available name' do
    user = FactoryGirl.create(:user,
                              first_name: 'first_name')
    assert_equal 'first_name', user.greeting

    user = FactoryGirl.create(:user,
                              first_name: nil)
    assert_includes user.greeting, 'fg_shortname'

    user = FactoryGirl.create(:user,
                              first_name: nil,
                              email: 'testmail@example.com',
                              shortname: nil)
    assert_equal user.greeting, 'testmail'
  end

  def notification_count(user)
    Argu::Redis.get("user:#{user.id}:notification.count").to_i
  end
end
