require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  ####################################
  # As user
  ####################################
  let(:user) { create(:user_with_memberships) }
  let!(:follower) { create :user, :follows_email }
  let!(:follow) do
    create(:follow,
           followable: user.profile.memberships.first.forum,
           follower: follower)
  end

  test 'should create and destroy motion with notifications' do
    log_in_user user

    assert_differences([['Motion.count', 1], ['Notification.count', 1]]) do
      post forum_motions_path(user.profile.memberships.first.forum),
           { motion: attributes_for(:motion) }
    end

    assert_differences([['Motion.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete motion_path(Motion.last)
    end
  end
end
