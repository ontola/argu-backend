# frozen_string_literal: true
require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:project) { create(:project, :with_follower, :with_news_follower, parent: freetown.edge) }
  let(:question) { create(:question, :with_follower, :with_news_follower, parent: project.edge) }
  let(:motion) { create(:motion, :with_follower, :with_news_follower, parent: question.edge) }
  let(:argument) { create(:argument, :with_follower, :with_news_follower, parent: motion.edge) }
  let(:comment) { create(:comment, parent: argument.edge) }
  let(:group) { create(:group, visibility: :discussion, parent: freetown.page.edge) }
  let(:group_membership) { create(:group_membership, parent: group.edge, member: user.profile) }
  let!(:random_follow) { create(:follow, followable: create_forum.edge) }
  let(:blog_post) do
    create(:blog_post,
           :with_follower,
           :with_news_follower,
           argu_publication: build(:publication),
           happening_attributes: {happened_at: DateTime.current},
           parent: motion.edge)
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should create and destroy motion with notifications' do
    sign_in member

    # Notification for follower of Forum
    assert_differences([['Motion.count', 1], ['Notification.count', 1]]) do
      post forum_motions_path(freetown),
           params: {motion: attributes_for(:motion)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Motion.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete motion_path(Motion.last)
    end
  end

  test 'member should create and destroy question with notifications' do
    sign_in member

    # Notification for follower of Forum
    assert_differences([['Question.count', 1], ['Notification.count', 1]]) do
      post forum_questions_path(freetown),
           params: {question: attributes_for(:question)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Question.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete question_path(Question.last)
    end
  end

  test 'member should create and destroy argument with notifications' do
    sign_in member
    motion

    # Notification for creator and follower of Motion
    assert_differences([['Argument.count', 1], ['Notification.count', 2]]) do
      post forum_arguments_path(freetown),
           params: {
             argument: attributes_for(:argument)
               .merge(motion_id: motion.id)
           }
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Argument.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete argument_path(Argument.last)
    end
  end

  test 'member should create and destroy comment with notifications' do
    sign_in member
    argument

    # Notification for creator and follower of Argument
    assert_differences([['Comment.count', 1], ['Notification.count', 2]]) do
      post argument_comments_path(argument),
           params: {comment: attributes_for(:comment)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Comment.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete destroy_argument_comment_path(argument, Comment.last)
    end
  end

  test 'member should create and destroy comment for blog_post with notifications' do
    sign_in member
    blog_post

    # Notification for creator and follower of BlogPost
    assert_differences([['Comment.count', 1], ['Notification.count', 2]]) do
      post blog_post_comments_path(blog_post),
           params: {comment: attributes_for(:comment)}
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Comment.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete destroy_blog_post_comment_path(blog_post, Comment.last)
    end
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should forward to self and approve with notifications' do
    sign_in manager
    motion

    assert_differences([['Decision.count', 1], ['Notification.count', 0]]) do
      post motion_decisions_path(motion.edge),
           params: {
             decision: attributes_for(:decision,
                                      state: 'forwarded',
                                      forwarded_user_id: manager.id,
                                      forwarded_group_id: freetown.edge.granted_groups('manager').first.id,
                                      content: 'Content',
                                      happening_attributes: {happened_at: Time.current},
                                      argu_publication_attributes: {publish_type: :direct})
           }
    end
    # Notification for creator and follower of Motion
    assert_differences([['Notification.count', 2]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Decision.count', 1], ['Notification.count', 0]]) do
      post motion_decisions_path(motion.edge),
           params: {
             decision: attributes_for(:decision,
                                      state: 'approved',
                                      content: 'Content',
                                      happening_attributes: {happened_at: Time.current},
                                      argu_publication_attributes: {publish_type: :direct})
           }
    end
    # Notification for creator, follower and news_follower of Motion
    assert_differences([['Notification.count', 3]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end
    assert_equal Notification.last.notification_type, 'decision'
  end

  test 'manager should forward to other with notification' do
    sign_in manager
    motion
    group_membership

    assert_differences([['Decision.count', 1], ['Notification.count', 0]]) do
      post motion_decisions_path(motion.edge),
           params: {
             decision: attributes_for(:decision,
                                      state: 'forwarded',
                                      forwarded_user_id: user.id,
                                      forwarded_group_id: group.id,
                                      content: 'Content',
                                      happening_attributes: {happened_at: Time.current},
                                      argu_publication_attributes: {publish_type: :direct})
           }
    end
    # Notification for creator and follower of Motion and forwarded_to_user
    assert_differences([['Notification.count', 3]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end
    assert_equal Notification.last.notification_type, 'reaction'
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test 'owner should create and destroy project with notifications' do
    sign_in owner

    assert_differences([['Project.count', 1]]) do
      post forum_projects_path(freetown),
           params: {
             project: attributes_for(:project,
                                     argu_publication_attributes: {publish_type: :direct})
           }
    end

    # Notification for follower of Forum
    assert_differences([['Notification.count', 1]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end
    assert_equal Notification.last.notification_type, 'reaction'

    assert_differences([['Project.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete project_path(Project.last)
    end
  end

  test 'owner should create and destroy blog_post with notifications' do
    sign_in owner

    assert_differences([['BlogPost.count', 1]]) do
      post project_blog_posts_path(project),
           params: {
             blog_post: attributes_for(:blog_post,
                                       argu_publication_attributes: {publish_type: :direct},
                                       happening_attributes: {happened_at: Time.current})
           }
    end

    # Notification for creator, follower and news_follower of Project
    assert_differences([['Notification.count', 3]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end
    assert_equal Notification.last.notification_type, 'news'

    assert_differences([['BlogPost.trashed_only.count', 1], ['Notification.count', -3]]) do
      delete blog_post_path(BlogPost.last)
    end
  end
end
