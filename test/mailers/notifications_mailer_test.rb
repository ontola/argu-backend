# frozen_string_literal: true
require 'test_helper'

class NotificationsMailerTest < ActionMailer::TestCase
  include MailerHelper
  define_freetown
  let!(:follower) { create(:user) }
  let!(:creator) { create(:profile) }
  let!(:publisher) { create(:user, profile: creator) }
  let(:group_member) { create(:group_membership, parent: group.edge, member: create(:user).profile).member.profileable }
  let(:group) { create(:group, parent: freetown.page.edge) }

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
           happening_attributes: {happened_at: DateTime.current})
  end
  let(:rejection) do
    create(:decision,
           creator: creator,
           parent: motion.edge,
           state: 'rejected',
           happening_attributes: {happened_at: DateTime.current})
  end
  let(:forward) do
    create(:decision,
           parent: motion.edge,
           state: 'forwarded',
           forwarded_user_id: group_member.id,
           forwarded_group_id: group.id,
           happening_attributes: {happened_at: DateTime.current})
  end
  let(:project) do
    create(:project,
           creator: creator,
           start_date: DateTime.yesterday,
           end_date: DateTime.tomorrow,
           parent: freetown.edge)
  end
  let(:blog_post) do
    create(:blog_post,
           creator: creator,
           happening_attributes: {happened_at: DateTime.current},
           parent: motion.edge)
  end

  test 'should send email for new question' do
    email = assert_deliver question.activities.second.notifications.where(user: follower)
    assert_email email, "New challenge: '#{question.display_name}' by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new motion' do
    email = assert_deliver motion.activities.second.notifications.where(user: follower)
    assert_email email, "New idea: '#{motion.display_name}' by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new question_motion' do
    email = assert_deliver question_motion.activities.second.notifications.where(user: follower)
    assert_email email, "New idea: '#{question_motion.display_name}' by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new argument_pro' do
    email = assert_deliver argument_pro.activities.first.notifications.where(user: follower)
    assert_email email, "New argument: '#{argument_pro.parent_model.display_name}'"\
                        " by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new argument_con' do
    email = assert_deliver argument_con.activities.first.notifications.where(user: follower)
    assert_email email, "New argument: '#{argument_con.parent_model.display_name}'"\
                        " by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new comment' do
    email = assert_deliver comment.activities.first.notifications.where(user: follower)
    assert_email email, "New comment on '#{comment.parent_model.display_name}'"\
                        " by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new comment_comment' do
    email = assert_deliver comment_comment.activities.first.notifications.where(user: follower)
    assert_email email, "New comment on '#{comment_comment.parent_model.display_name}'"\
                        " by #{publisher.first_name} #{publisher.last_name}"
  end

  test 'should send email for new approval' do
    email = assert_deliver decision.activities.second.notifications.where(user: follower)
    assert_email email, "'#{motion.display_name}' is approved"
  end

  test 'should send email for new rejection' do
    email = assert_deliver rejection.activities.second.notifications.where(user: follower)
    assert_email email, "'#{motion.display_name}' is rejected"
  end

  test 'should send email for new forward' do
    email = assert_deliver forward.activities.second.notifications.where(user: follower)
    assert_email email, "'#{motion.display_name}' is forwarded"
  end

  test 'should send email for new blog_post' do
    email = assert_deliver blog_post.activities.second.notifications.where(user: follower)
    assert_email email, "New update: '#{blog_post.display_name}'"
  end

  test 'should send email for new project' do
    email = assert_deliver project.activities.second.notifications.where(user: follower)
    assert_email email, "New project: '#{project.display_name}'"\
                        " by #{publisher.first_name} #{publisher.last_name}"
  end

  private

  def assert_deliver(notifications)
    email = NotificationsMailer.notifications_email(follower, notifications)
    assert_emails 1 do
      email.deliver_now
    end
    email
  end

  def assert_email(email, subject)
    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal subject, email.subject
  end
end
