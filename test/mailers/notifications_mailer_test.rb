# frozen_string_literal: true
require 'test_helper'

class NotificationsMailerTest < ActionMailer::TestCase
  include MailerHelper
  define_freetown
  let!(:follower) { create(:user) }
  let!(:creator) { create(:profile) }
  let!(:publisher) { create(:user, profile: creator) }

  let!(:follow_forum) { create(:follow, followable: freetown.edge, follower: follower) }
  let(:question) { create(:question, :with_follower, creator: creator, parent: freetown.edge) }
  let!(:follow_question) { create(:follow, followable: question.edge, follower: follower) }
  let(:motion) { create(:motion, :with_follower, creator: creator, parent: freetown.edge) }
  let!(:follow_motion) { create(:follow, followable: motion.edge, follower: follower) }
  let(:question_motion) { create(:motion, creator: creator, parent: question.edge) }
  let(:argument_pro) { create(:argument, creator: creator, pro: true, parent: motion.edge) }
  let!(:follow_argument) { create(:follow, followable: argument_pro.edge, follower: follower) }
  let(:argument_con) { create(:argument, creator: creator, pro: false, parent: motion.edge) }
  let(:comment) { create(:comment, creator: creator, parent: argument_pro.edge) }
  let!(:follow_comment) { create(:follow, followable: comment.edge, follower: follower) }
  let(:comment_comment) do
    comment_comment = create(:comment,
                             parent: argument_pro.edge,
                             creator: creator)
    comment_comment.move_to_child_of comment
  end
  let(:decision) do
    create(:decision,
           creator: creator,
           parent: motion.edge,
           state: 'approved',
           happening_attributes: {happened_at: DateTime.current},
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}})
  end
  let(:project) do
    create(:project,
           creator: creator,
           start_date: DateTime.yesterday,
           end_date: DateTime.tomorrow,
           parent: freetown.edge,
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}})
  end
  let(:blog_post) do
    create(:blog_post,
           creator: creator,
           happening_attributes: {happened_at: DateTime.current},
           parent: motion.edge,
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}})
  end

  test 'should send email for new question' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              question.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New challenge: '#{question.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new motion' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              motion.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New idea: '#{motion.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new question_motion' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              question_motion.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New idea: '#{question_motion.display_name}' by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new argument_pro' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              argument_pro.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New argument: '#{argument_pro.motion.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new argument_con' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              argument_con.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New argument: '#{argument_con.motion.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new comment' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              comment.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New comment on '#{comment.commentable.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new comment_comment' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              comment_comment.activities.first.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New comment on '#{comment_comment.commentable.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'should send email for new decision' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              decision.activities.second.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "A decision was made on '#{motion.display_name}'",
                 email.subject
  end

  test 'should send email for new blog_post' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              blog_post.activities.second.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New update: '#{blog_post.display_name}'",
                 email.subject
  end

  test 'should send email for new project' do
    email = NotificationsMailer
            .notifications_email(
              follower,
              project.activities.second.notifications.where(user: follower)
            )
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal "New project: '#{project.display_name}'"\
                   " by #{publisher.first_name} #{publisher.last_name}",
                 email.subject
  end

  test 'action_path should return paths' do
    [question, motion, argument_pro, comment].each do |item|
      assert action_path(item.activities.first.notifications.first).length > 13
    end
    [blog_post, project, decision].each do |item|
      assert action_path(item.activities.second.notifications.first).length > 13
    end
  end
end
