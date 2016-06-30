require 'test_helper'

class MailerHelperTest < ActionView::TestCase
  include MailerHelper

  define_freetown
  let!(:follower) { create(:follow, followable: freetown.edge) }
  let!(:creator) { create(:profile) }
  let!(:publisher) { create(:user, profile: creator) }

  let(:question) { create(:question, :with_follower, creator: creator, parent: freetown.edge) }
  let(:motion) { create(:motion, :with_follower, creator: creator, parent: freetown.edge) }
  let(:motion_question) { create(:motion, creator: creator, parent: question.edge) }
  let(:argument_pro) { create(:argument, creator: creator, pro: true, parent: motion.edge) }
  let(:argument_con) { create(:argument, creator: creator, pro: false, parent: motion.edge) }
  let(:comment) { create(:comment, creator: creator, parent: argument_pro.edge) }
  let(:comment_comment) do
    comment_comment = create(:comment,
                             parent: argument_pro.edge,
                             creator: creator)
    comment_comment.move_to_child_of comment
  end

  test 'notification_subject should return correct sentences for questions' do
    assert_equal "New challenge: '#{question.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(question.activities.first.notifications.first)
  end

  test 'notification_subject should return correct sentences for motions' do
    assert_equal "New idea: '#{motion.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(motion.activities.first.notifications.first)

    assert_equal "New idea: '#{motion_question.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(motion_question.activities.first.notifications.first)
  end

  test 'notification_subject should return correct sentences for arguments' do
    assert_equal "New argument: '#{argument_pro.motion.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(argument_pro.activities.first.notifications.first)

    assert_equal "New argument: '#{argument_con.motion.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(argument_con.activities.first.notifications.first)
  end

  test 'notification_subject should return correct sentences for comments' do
    assert_equal "New comment on '#{comment.commentable.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(comment.activities.first.notifications.first)

    assert_equal "New comment on '#{comment_comment.commentable.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 notification_subject(comment_comment.activities.first.notifications.first)
  end

  test 'action_path should return paths' do
    [question, motion, argument_pro, comment].each do |item|
      assert action_path(item.activities.first.notifications.first).length > 13
    end
  end
end
