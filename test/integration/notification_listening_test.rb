# frozen_string_literal: true

require 'test_helper'

class NotificationListeningTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:question) { create(:question, :with_follower, :with_news_follower, parent: freetown) }
  let(:motion) { create(:motion, :with_follower, :with_news_follower, parent: question) }
  let(:topic) { create(:topic, :with_follower, :with_news_follower, parent: freetown) }
  let(:argument) { create(:argument, :with_follower, :with_news_follower, parent: motion) }
  let(:comment) { create(:comment, parent: argument) }
  let(:group) { create(:group, parent: argu) }
  let(:group_membership) { create(:group_membership, parent: group, member: user.profile) }
  let!(:random_follow) { create(:follow, followable: create_forum) }
  let(:blog_post) do
    create(:blog_post,
           :with_follower,
           :with_news_follower,
           parent: motion)
  end
  let(:staff) { create(:user, :staff) }

  test 'staff should create and trash motion with notifications' do
    sign_in staff

    # Notification for follower of Forum
    assert_difference('Motion.count' => 1, 'Notification.count' => 0) do
      post collection_iri(freetown, :motions),
           params: {motion: attributes_for(:motion)}
    end

    assert_notifications(1, 'reaction', 'Motion.published.count' => 1)

    assert_difference('Motion.trashed.count' => 1, create_notification_count => -1) do
      delete Motion.last
    end
  end

  test 'staff should destroy topic with notifications' do
    sign_in staff

    topic

    assert_difference('Topic.count' => -1, create_notification_count => -1) do
      delete topic.iri(destroy: true)
    end
  end

  test 'staff should destroy motion with notifications' do
    sign_in staff

    motion

    assert_difference('Motion.count' => -1, create_notification_count => -2) do
      delete motion.iri(destroy: true)
    end
  end

  test 'staff should create and trash question with notifications' do
    sign_in staff

    # Notification for follower of Forum
    assert_difference('Question.count' => 1, 'Notification.count' => 0) do
      post collection_iri(freetown, :questions),
           params: {question: attributes_for(:question)}
    end

    assert_notifications(1, 'reaction', 'Question.published.count' => 1)

    assert_difference('Question.trashed.count' => 1, create_notification_count => -1) do
      delete Question.last
    end
  end

  test 'staff should destroy question with notifications' do
    sign_in staff

    question

    assert_difference('Question.count' => -1, create_notification_count => -1) do
      delete question.iri(destroy: true)
    end
  end

  test 'staff should create and trash argument with notifications' do
    sign_in staff
    motion

    # Notification for creator and follower of Motion
    assert_difference('Argument.count' => 1, 'Notification.count' => 2) do
      post collection_iri(motion, :pro_arguments),
           params: {
             pro_argument: attributes_for(:argument)
           }
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_difference('Argument.trashed.count' => 1, create_notification_count => -2) do
      delete Argument.last
    end
  end

  test 'staff should destroy argument with notifications' do
    sign_in staff

    argument

    assert_difference('Argument.count' => -1, create_notification_count => -2) do
      delete argument.iri(destroy: true)
    end
  end

  test 'staff should create and trash comment with notifications' do
    sign_in staff
    argument

    # Notification for creator and follower of Argument
    assert_difference('Comment.count' => 1, 'Notification.count' => 2) do
      post collection_iri(argument, :comments),
           params: {comment: attributes_for(:comment)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_difference('Comment.trashed.count' => 1, create_notification_count => -2) do
      delete Comment.last
    end
  end

  test 'staff should create and trash comment for blog_post with notifications' do
    sign_in staff
    blog_post

    # Notification for creator and follower of BlogPost
    assert_difference('Comment.count' => 1, 'Notification.count' => 2) do
      post collection_iri(blog_post, :comments),
           params: {comment: attributes_for(:comment)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_difference('Comment.trashed.count' => 1, create_notification_count => -2) do
      delete Comment.last
    end
  end

  test 'staff should create and trash comment for motion with notifications' do
    sign_in staff
    motion

    # Notification for creator and follower of Motion
    assert_difference('Comment.count' => 1, 'Notification.count' => 2) do
      post collection_iri(motion, :comments),
           params: {comment: attributes_for(:comment)}
    end
    assert_equal Notification.last.notification_type, 'reaction'
    assert_equal(
      motion.followings.reactions.pluck(:follower_id).sort,
      Notification.order(created_at: :desc).limit(2).pluck(:user_id).sort
    )

    assert_difference('Comment.trashed.count' => 1, create_notification_count => -2) do
      delete Comment.last
    end
  end

  test 'staff should create and trash nested comment for motion with notifications' do
    sign_in staff
    comment

    # Notification for creator and follower of Argument and of parent comment
    assert_difference('Comment.count' => 1, 'Notification.count' => 3) do
      post collection_iri(argument, :comments),
           params: {comment: attributes_for(:comment).merge(in_reply_to_id: comment.uuid)}
    end
    assert_equal Notification.last.notification_type, 'reaction'
    assert_equal(
      (comment.followings.reactions.pluck(:follower_id) + argument.followings.reactions.pluck(:follower_id)).uniq.sort,
      Notification.order(created_at: :desc).limit(3).pluck(:user_id).sort
    )

    assert_difference('Comment.trashed.count' => 1, create_notification_count => -3) do
      delete Comment.last
    end
  end

  test 'staff should create and trash blog_post with notifications' do
    sign_in staff

    assert_difference('BlogPost.count' => 1) do
      post collection_iri(question, :blog_posts),
           params: {
             blog_post: attributes_for(:blog_post)
           }
    end

    # Notification for creator, follower and news_follower of Question
    assert_notifications(3, 'news')

    assert_difference('BlogPost.trashed.count' => 1, create_notification_count => -3) do
      delete BlogPost.last
    end
  end

  test 'staff should forward to other with notification' do
    sign_in staff
    motion
    group_membership

    assert_difference('Decision.count' => 1, 'Notification.count' => 0) do
      post collection_iri(motion, :decisions),
           params: {
             decision: attributes_for(:decision,
                                      state: 'forwarded',
                                      forwarded_user_id: user.id,
                                      forwarded_group_id: group.id,
                                      content: 'Content')
           }
    end
    # Notification for creator and follower of Motion and forwarded_to_user
    assert_notifications(3, 'reaction')
  end

  test 'staff should forward to self and approve with notifications' do
    sign_in staff
    motion
    create(:group_membership, parent: group, member: staff.profile)
    assert_difference('Decision.count' => 1, 'Notification.count' => 0) do
      post collection_iri(motion, :decisions),
           params: {
             decision: attributes_for(:decision,
                                      state: 'forwarded',
                                      forwarded_user_id: staff.id,
                                      forwarded_group_id: group.id,
                                      content: 'Content')
           }
    end
    # Notification for creator and follower of Motion
    assert_notifications(2, 'reaction')

    assert_difference('Decision.count' => 1, 'Notification.count' => 0) do
      post collection_iri(motion, :decisions),
           params: {
             decision: attributes_for(:decision,
                                      state: 'approved',
                                      content: 'Content')
           }
    end
    # Notification for creator, follower and news_follower of Motion
    assert_notifications(3, 'news')
  end

  private

  def create_notification_count
    'Notification.joins(:activity).where("key ~ \'*.create|publish\'").count'
  end

  def assert_notifications(count, type, differences = {})
    assert_difference(differences.merge('Notification.count' => count)) do
      ActsAsTenant.with_tenant(Publication.last.publishable.root) { reset_publication(Publication.last) }
    end
    assert_equal Notification.last.notification_type, type
  end
end
