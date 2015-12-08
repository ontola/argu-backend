require 'test_helper'

class MailerHelperTest < ActionView::TestCase
  include MailerHelper

  let!(:holland) { FactoryGirl.create(:populated_forum) }
  let!(:creator) { FactoryGirl.create(:user) }

  let(:question) do
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_question,
                                                    owner: creator.profile,
                                                    forum: holland))
  end

  let(:motion) do
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_motion,
                                                    owner: creator.profile,
                                                    forum: holland))
  end

  let(:motion_question) do
    question = FactoryGirl.create(:question)
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_motion,
                                                    owner: creator.profile,
                                                    recipient: question,
                                                    forum: holland))
  end

  let(:argument_pro) do
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_argument,
                                                    owner: creator.profile,
                                                    forum: holland))
  end

  let(:argument_con) do
    argument = FactoryGirl.create(:argument,
                       forum: holland,
                       creator: creator.profile,
                       pro: false)

    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_argument,
                                                    forum: holland,
                                                    trackable: argument,
                                                    recipient: argument.motion))
  end

  let(:comment) do
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_comment,
                                                    forum: holland,
                                                    owner: creator.profile))
  end

  let(:comment_comment) do
    comment = FactoryGirl.create(:comment)
    FactoryGirl.create(:notification,
                       activity: FactoryGirl.create(:activity,
                                                    :t_comment,
                                                    owner: creator.profile,
                                                    recipient: comment,
                                                    forum: holland))
  end

  test 'notification_subject should return correct sentences for questions' do
    assert_equal "Nieuw vraagstuk: '#{question.resource.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(question)
  end

  test 'notification_subject should return correct sentences for motions' do
    assert_equal "Nieuw idee: '#{motion.resource.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(motion)

    assert_equal "Nieuw idee: '#{motion_question.resource.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(motion_question)
  end

  test 'notification_subject should return correct sentences for arguments' do
    assert_equal "Nieuw argument voor '#{argument_pro.resource.motion.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(argument_pro)

    assert_equal "Nieuw argument tegen '#{argument_con.resource.motion.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(argument_con)
  end

  test 'notification_subject should return correct sentences for comments' do
    assert_equal "Nieuwe reactie op '#{comment.resource.commentable.display_name}' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(comment)

    assert_equal "Nieuwe reactie op 'comment' door #{creator.first_name} #{creator.last_name}",
                 notification_subject(comment_comment)
  end

  test 'action_path should return paths' do
    [question, motion, argument_pro, comment].each do |item|
      assert action_path(item).length > 13
    end
  end
end
