require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  let(:freetown) { create(:forum, :with_follower, name: 'freetown') }
  let(:project) { create(:project, :with_follower, forum: freetown) }
  let(:question) { create(:question, :with_follower, project: project, forum: freetown) }
  let(:motion) { create(:motion, :with_follower, question: question, forum: freetown) }
  let(:argument) { create(:argument, :with_follower, motion: motion, forum: freetown) }
  let(:comment) { create(:comment, commentable: argument, forum: freetown) }
  let(:group) { create(:group, :discussion, forum: freetown) }
  let(:group_membership) { create(:group_membership, group: group, member: user.profile) }
  let!(:random_follow) { create(:follow, followable: create(:forum).edge) }
  ####################################
  # As User
  ####################################
  let(:user) { create_member(freetown) }

  test 'user should create and destroy motion with notifications' do
    sign_in user

    assert_differences([['Motion.count', 1], ['Notification.count', 1]]) do
      post forum_motions_path(freetown),
           motion: attributes_for(:motion)
    end

    assert_differences([['Motion.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete motion_path(Motion.last)
    end
  end

  test 'user should create and destroy question with notifications' do
    sign_in user

    assert_differences([['Question.count', 1], ['Notification.count', 1]]) do
      post forum_questions_path(freetown),
           question: attributes_for(:question)
    end

    assert_differences([['Question.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete question_path(Question.last)
    end
  end

  test 'user should create and destroy argument with notifications' do
    # Both the motion publisher as the motion follower will receive a notification
    sign_in user

    assert_differences([['Argument.count', 1], ['Notification.count', 2]]) do
      post forum_arguments_path(freetown),
           argument: attributes_for(:argument)
                       .merge(motion_id: motion.id)
    end

    assert_differences([['Argument.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete argument_path(Argument.last)
    end
  end

  test 'user should create and destroy group_response with notifications' do
    # Both the motion publisher as the motion follower will receive a notification
    sign_in user
    group_membership

    assert_differences([['GroupResponse.count', 1], ['Notification.count', 2]]) do
      post motion_group_group_responses_path(motion, group),
           group_response: {
             side: :pro,
             forum_id: freetown.id
           }
    end

    assert_differences([['GroupResponse.count', -1], ['Notification.count', -2]]) do
      delete group_response_path(GroupResponse.last)
    end
  end

  test 'user should create and destroy comment with notifications' do
    # Both the argument publisher as the argument follower will receive a notification
    sign_in user

    assert_differences([['Comment.count', 1], ['Notification.count', 2]]) do
      post argument_comments_path(argument),
           comment: attributes_for(:comment)
    end

    assert_differences([['Comment.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete destroy_argument_comment_path(argument, Comment.last)
    end
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should create and destroy project with notifications' do
    sign_in create_owner(freetown)

    assert_differences([['Project.count', 1]]) do
      post forum_projects_path(freetown),
           project: attributes_for(:project,
                                   argu_publication_attributes: {publish_type: :direct})
    end

    assert_differences([['Notification.count', 1]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end

    assert_differences([['Project.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete project_path(Project.last)
    end
  end

  test 'owner should create and destroy blog_post with notifications' do
    sign_in create_owner(freetown)

    assert_differences([['BlogPost.count', 1]]) do
      post project_blog_posts_path(project),
           blog_post: attributes_for(:blog_post,
                                     argu_publication_attributes: {publish_type: :direct},
                                     happened_at: DateTime.current)
    end

    # Notification for creator and follower of Project
    assert_differences([['Notification.count', 2]]) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end

    assert_differences([['BlogPost.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete blog_post_path(BlogPost.last)
    end
  end
end
