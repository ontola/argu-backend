# frozen_string_literal: true

require 'test_helper'

class NotificationsMailerTest < ActionMailer::TestCase
  include ActivityHelper
  include MailerHelper
  include DecisionsHelper
  include BlogPostsHelper
  include Rails.application.routes.url_helpers

  define_freetown
  let!(:follower) { create(:user) }
  let!(:creator) { create(:profile) }
  let!(:publisher) { create(:user, profile: creator) }
  let(:group_member) { create(:group_membership, parent: group, member: create(:user).profile).member.profileable }
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
    assert_email(
      notification: question.activities.second.notifications.find_by(user: follower),
      subject: "New challenge: '#{question.display_name}' by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  test 'should send email for trashing question' do
    trash_resource(question)
    assert_email(
      notification: question.trash_activity.notifications.find_by(user: follower),
      subject: "'#{question.display_name}' is trashed"
    )
  end

  test 'should send email for new motion' do
    assert_email(
      notification: motion.activities.second.notifications.find_by(user: follower),
      subject: "New idea: '#{motion.display_name}' by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  test 'should send email for trashing motion' do
    trash_resource(motion)
    assert_email(
      notification: motion.trash_activity.notifications.find_by(user: follower),
      subject: "'#{motion.display_name}' is trashed"
    )
  end

  test 'should send email for new question_motion' do
    assert_email(
      notification: question_motion.activities.second.notifications.find_by(user: follower),
      subject: "New idea: '#{question_motion.display_name}' by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  test 'should send email for new argument_pro' do
    assert_email(
      notification: argument_pro.activities.first.notifications.find_by(user: follower),
      subject: "New argument: '#{argument_pro.parent_model.display_name}'"\
               " by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  test 'should send email for new argument_con' do
    assert_email(
      notification: argument_con.activities.first.notifications.find_by(user: follower),
      subject: "New argument: '#{argument_con.parent_model.display_name}'"\
               " by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  test 'should send email for trashing argument' do
    trash_resource(argument_pro)
    assert_email(
      notification: argument_pro.trash_activity.notifications.find_by(user: follower),
      subject: "'#{argument_pro.display_name}' is trashed"
    )
  end

  test 'should send email for new comment' do
    assert_email(
      notification: comment.activities.first.notifications.find_by(user: follower),
      subject: "New comment on '#{comment.parent_model.display_name}'"\
               " by #{publisher.first_name} #{publisher.last_name}",
      title_link: comment.body
    )
  end

  test 'should send email for trashing comment' do
    trash_resource(comment)
    assert_email(
      notification: comment.trash_activity.notifications.find_by(user: follower),
      subject: 'Comment is trashed',
      title_link: 'comment'
    )
  end

  test 'should send email for new comment_comment' do
    assert_email(
      notification: comment_comment.activities.first.notifications.find_by(user: follower),
      subject: "New comment on '#{comment_comment.parent_model.display_name}'"\
               " by #{publisher.first_name} #{publisher.last_name}",
      title_link: comment_comment.body
    )
  end

  test 'should send email for new approval' do
    assert_email(
      notification: decision.activities.second.notifications.find_by(user: follower),
      subject: "'#{motion.display_name}' is approved",
      title_link: false
    )
  end

  test 'should send email for new rejection' do
    assert_email(
      notification: rejection.activities.second.notifications.find_by(user: follower),
      subject: "'#{motion.display_name}' is rejected",
      title_link: false
    )
  end

  test 'should send email for new forward' do
    assert_email(
      notification: forward.activities.second.notifications.find_by(user: follower),
      subject: "'#{motion.display_name}' is forwarded",
      title_link: false
    )
  end

  test 'should send email for new blog_post' do
    assert_email(
      notification: blog_post.activities.second.notifications.find_by(user: follower),
      subject: "New update: '#{blog_post.display_name}'",
      url: url_for_blog_post(blog_post)
    )
  end

  test 'should send email for trashing blog_post' do
    trash_resource(blog_post)
    assert_email(
      notification: blog_post.trash_activity.notifications.find_by(user: blog_post.publisher),
      subject: "'#{blog_post.display_name}' is trashed",
      url: url_for_blog_post(blog_post)
    )
  end

  test 'should send email for new project' do
    assert_email(
      notification: project.activities.second.notifications.find_by(user: follower),
      subject: "New project: '#{project.display_name}' by #{publisher.first_name} #{publisher.last_name}"
    )
  end

  private

  def assert_email(notification: nil, subject: nil, url: nil, title_link: nil)
    url ||= url_for(notification.activity.trackable)
    email = NotificationsMailer.notifications_email(follower, [notification])

    assert_emails 1 { email.deliver_now }
    assert_select_email do
      assert_select 'a[href=?]', url, text: 'Go to discussion'
      unless title_link == false
        assert_select 'a[href=?]', url, text: title_link || notification.activity.trackable.display_name
      end
    end
    assert_equal ['noreply@argu.co'], email.from
    assert_equal [follower.email], email.to
    assert_equal subject, email.subject
  end

  def trash_resource(resource, user: create(:user))
    TrashService.new(resource, options: {creator: user.profile, publisher: user}).commit
  end
end
