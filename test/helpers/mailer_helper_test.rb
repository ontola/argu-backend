require 'test_helper'

class MailerHelperTest < ActionView::TestCase
  include MailerHelper

  let!(:holland) { create(:populated_forum) }
  let!(:creator) { create(:user) }

  let(:question) do
    create(:notification,
           activity: create(:activity,
                            :t_question,
                            owner: creator.profile,
                            forum: holland))
  end

  let(:motion) do
    create(:notification,
           activity: create(:activity,
                            :t_motion,
                            owner: creator.profile,
                            forum: holland))
  end

  let(:motion_question) do
    question = create(:question)
    create(:notification,
           activity: create(:activity,
                            :t_motion,
                            owner: creator.profile,
                            recipient: question,
                            forum: holland))
  end

  let(:argument_pro) do
    create(:argument,
           forum: holland,
           pro: true)
  end

  let(:argument_pro_notification) do
    create(:notification,
           activity: create(:activity,
                            :t_argument,
                            owner: creator.profile,
                            forum: holland))
  end

  let(:argument_con) do
    argument = create(:argument,
                       forum: holland,
                       creator: creator.profile,
                       pro: false)

    create(:notification,
           activity: create(:activity,
                            :t_argument,
                            forum: holland,
                            trackable: argument,
                            recipient: argument.motion))
  end

  let(:comment) do
    _comment = create(:comment,
                     commentable: argument_pro,
                     profile: creator.profile)
    create(:notification,
           activity: create(:activity,
                            forum: holland,
                            trackable: _comment,
                            recipient: argument_pro,
                            owner: creator.profile))
  end

  let(:comment_comment) do
    comment = create(:comment,
                     commentable: argument_pro)
    comment_comment = create(:comment,
                             commentable: argument_pro,
                             profile: creator.profile)
    comment_comment.move_to_child_of comment
    create(:notification,
           activity: create(:activity,
                            forum: holland,
                            trackable: comment_comment,
                            recipient: argument_pro,
                            owner: creator.profile))
  end

  test 'notification_subject should return correct sentences for questions' do
    assert_equal "New challenge: '#{question.resource.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(question)
  end

  test 'notification_subject should return correct sentences for motions' do
    assert_equal "New idea: '#{motion.resource.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(motion)

    assert_equal "New idea: '#{motion_question.resource.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(motion_question)
  end

  test 'notification_subject should return correct sentences for arguments' do
    assert_equal "New argument: '#{argument_pro_notification.resource.motion.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(argument_pro_notification)

    assert_equal "New argument: '#{argument_con.resource.motion.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(argument_con)
  end

  test 'notification_subject should return correct sentences for comments' do
    assert_equal "New comment on '#{comment.resource.commentable.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(comment)

    assert_equal "New comment on '#{comment_comment.resource.commentable.display_name}' by #{creator.first_name} #{creator.last_name}",
                 notification_subject(comment_comment)
  end

  test 'action_path should return paths' do
    [question, motion, argument_pro_notification, comment].each do |item|
      assert action_path(item).length > 13
    end
  end
end
