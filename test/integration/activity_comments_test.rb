# frozen_string_literal: true
require 'test_helper'

class ActivityCommentsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Super admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  test 'super admin should trash without comment' do
    sign_in super_admin
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion_path(motion)
    end
    assert_nil Activity.last.comment
    assert_equal Notification.last.title, "#{super_admin.display_name} trashed #{motion.display_name}"
  end

  test 'super admin should trash with comment' do
    sign_in super_admin
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion_path(motion), params: {activity: {comment: 'Reason for trashing'}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.title, "#{super_admin.display_name} trashed #{motion.display_name}"
  end

  test 'super admin should trash with comment as page' do
    sign_in super_admin
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion_path(motion),
             params: {actor_iri: freetown.page.context_id, activity: {comment: 'Reason for trashing'}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.title, "#{freetown.page.display_name} trashed #{motion.display_name}"
  end
end
