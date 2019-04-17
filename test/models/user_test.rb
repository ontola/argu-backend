# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  define_freetown
  subject do
    user = create(:user)
    ActsAsTenant.with_tenant(argu) do
      create(:notification,
             user: user,
             root_id: argu.uuid,
             activity: create(
               :activity,
               recipient: freetown,
               recipient_type: 'Forum',
               trackable: create(:motion, parent: freetown),
               trackable_type: 'Motion',
               root_id: freetown.root_id
             ),
             forum: freetown)
    end
    user
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should sync notification count' do
    assert_equal 0, notification_count(subject)
    subject.sync_notification_count
    assert_equal 1, notification_count(subject)
  end

  test 'should greet with best available name' do
    user = create(:user,
                  first_name: 'first_name')
    assert_equal 'first_name', user.greeting

    user = create(:user,
                  first_name: nil)
    assert_includes user.greeting, 'fg_shortname'

    user = create(:user,
                  first_name: nil,
                  email: 'testmail@example.com',
                  shortname: nil)
    assert_equal user.greeting, 'testmail'
  end

  test 'should adjust birthday' do
    subject.update('birthday(2i)' => '1', 'birthday(3i)' => '1', 'birthday(1i)' => '1970')
    assert_equal Date.new(1970, 7, 1), subject.birthday
  end

  test 'should validate r' do
    subject.r = ''
    assert subject.valid?, subject.errors.to_a.join(',').to_s
    subject.r = '/users/sign_in'
    assert subject.valid?, subject.errors.to_a.join(',').to_s
    subject.r = 'https://argu.dev/users/sign_in'
    assert subject.valid?, subject.errors.to_a.join(',').to_s
    subject.r = 'https://argu.dev/users/sign_in?param=blabla'
    assert subject.valid?, subject.errors.to_a.join(',').to_s
    subject.r = 'https://beta.argu.dev/users/sign_in?param=blabla'
    assert_not subject.valid?
    subject.r = 'https://evilwebsite.com/users/sign_in'
    assert_not subject.valid?
    subject.r = 'https://evilwebsite.com/users/sign_in?param=blabla'
    assert_not subject.valid?
  end

  test 'hide last_name' do
    assert_equal subject.display_name, "#{subject.first_name} #{subject.last_name}"
    subject.update(hide_last_name: true)
    assert_equal subject.display_name, subject.first_name
  end

  test 'minor should hide first_name' do
    assert_equal subject.hide_last_name, false
    subject.update!(birthday: 19.years.ago)
    assert_equal subject.reload.hide_last_name, false
    subject.update!(birthday: 18.years.ago)
    assert_equal subject.reload.hide_last_name, true
  end

  private

  def notification_count(user)
    Argu::Redis.get("user:#{user.id}:notification.count").to_i
  end
end
