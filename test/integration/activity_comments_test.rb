# frozen_string_literal: true

require 'test_helper'

class ActivityCommentsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Super admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should trash without comment' do
    sign_in administrator
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion
    end
    assert_nil Activity.last.comment
    assert_equal Notification.last.title, "#{administrator.display_name} trashed #{motion.display_name}"
  end

  test 'administrator should trash with comment' do
    sign_in administrator
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion, params: {activity: {comment: 'Reason for trashing'}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.title, "#{administrator.display_name} trashed #{motion.display_name}"
  end

  test 'administrator should trash with comment as page' do
    sign_in administrator
    motion

    assert_differences([['Motion.trashed.count', 1], ['Notification.last.id', 1]]) do
      delete motion,
             params: {actor_iri: argu.iri, activity: {comment: 'Reason for trashing'}}
    end

    comment = motion.activities.last.comment
    assert_equal comment, 'Reason for trashing'
    assert_equal Notification.last.title, "#{argu.display_name} trashed #{motion.display_name}"
  end
end
