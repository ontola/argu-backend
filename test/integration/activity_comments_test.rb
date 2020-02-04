# frozen_string_literal: true

require 'test_helper'

class ActivityCommentsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }

  ####################################
  # As Super admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should trash without comment' do
    sign_in administrator
    motion

    assert_difference('Motion.trashed.count' => 1, 'Notification.last.id' => 1) do
      delete motion
    end
    assert_nil Activity.last.comment
    assert_equal Notification.last.display_name, "#{administrator.display_name} trashed #{motion.display_name}"
  end

  test 'administrator should trash with comment' do
    sign_in administrator
    motion

    assert_difference('Motion.trashed.count' => 1, 'Notification.last.id' => 1) do
      delete motion, params: {motion: {trash_activity_attributes: {comment: 'Reason for trashing'}}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.display_name, "#{administrator.display_name} trashed #{motion.display_name}"
  end

  test 'administrator should trash with comment as page' do
    sign_in administrator
    motion

    assert_difference('Motion.trashed.count' => 1, 'Notification.last.id' => 1) do
      delete motion,
             params: {actor_iri: argu.iri, motion: {trash_activity_attributes: {comment: 'Reason for trashing'}}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.display_name, "#{argu.display_name} trashed #{motion.display_name}"
  end
end
