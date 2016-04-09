require 'test_helper'

class MotionsTest < ActionDispatch::IntegrationTest
  let!(:freetown) { create(:forum, name: 'freetown') }
  let!(:follower) { create(:follow, followable: freetown) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should show tutorial only on first post create' do
    log_in_user user
    create(:membership,
           profile: user.profile,
           forum: freetown)

    assert_differences create_changes_array do
      post forum_motions_path(freetown),
           motion: {
            title: 'Motion',
            content: 'Contents'
           }
    end
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource, start_motion_tour: true)

    assert_differences create_changes_array(false) do
      post forum_motions_path(freetown),
           motion: {
              title: 'Motion2',
              content: 'Contents'
           }
    end
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource)
  end

  private

  # Detect the changes that should go hand in hand with object creation
  # @param notifications [Boolean] Set to false if an object is created twice for the same follower
  def create_changes_array(notifications = true, count = 1)
    c = [['Motion.count', count],
         ['Activity.count', count],
         ['Notification.count', count]]
    c << ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', count] if notifications
    c
  end
end
