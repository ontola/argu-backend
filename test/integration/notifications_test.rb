require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user_with_memberships) }
  let!(:follower) { create :user, :follows_email }
  let!(:follow_forum) do
    create(:follow,
           followable: user.profile.memberships.first.forum,
           follower: follower)
  end
  let!(:follow_motion) do
    create(:follow,
           followable: create(:motion, forum: user.profile.memberships.first.forum),
           follower: follower)
  end
  let!(:follow_argument) do
    create(:follow,
           followable: create(:argument, forum: user.profile.memberships.first.forum),
           follower: follower)
  end
  let!(:follow_project) do
    create(:follow,
           followable: create(:project, forum: user.profile.memberships.first.forum),
           follower: follower)
  end
  let(:group) { create(:group, :discussion, forum: user.profile.memberships.first.forum) }
  let(:group_membership) { create(:group_membership, group: group, member: user.profile) }

  test 'should create and destroy motion with notifications' do
    sign_in user

    assert_differences([['Motion.count', 1], ['Notification.count', 1]]) do
      post forum_motions_path(user.profile.memberships.first.forum),
           motion: attributes_for(:motion)
    end

    assert_differences([['Motion.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete motion_path(Motion.last)
    end
  end

  test 'should create and destroy question with notifications' do
    sign_in user

    assert_differences([['Question.count', 1], ['Notification.count', 1]]) do
      post forum_questions_path(user.profile.memberships.first.forum),
           question: attributes_for(:question)
    end

    assert_differences([['Question.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete question_path(Question.last)
    end
  end

  test 'should create and destroy project with notifications' do
    Forum.first.page.update(owner_id: user.profile.id)
    sign_in user

    assert_differences([['Project.count', 1], ['Notification.count', 1]]) do
      post forum_projects_path(user.profile.memberships.first.forum),
           project: attributes_for(:project)
    end

    assert_differences([['Project.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete project_path(Project.last)
    end
  end

  test 'should create and destroy argument with notifications' do
    # Both the motion publisher as the motion follower will receive a notification
    sign_in user

    assert_differences([['Argument.count', 1], ['Notification.count', 2]]) do
      post forum_arguments_path(user.profile.memberships.first.forum),
           argument: attributes_for(:argument)
                       .merge(motion_id: follow_motion.followable.id)
    end

    assert_differences([['Argument.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete argument_path(Argument.last)
    end
  end

  test 'should create and destroy group_response with notifications' do
    # Both the motion publisher as the motion follower will receive a notification
    sign_in user
    group_membership

    assert_differences([['GroupResponse.count', 1], ['Notification.count', 2]]) do
      post motion_group_group_responses_path(follow_motion.followable, group),
           group_response: {
             side: :pro,
             forum_id: user.profile.memberships.first.forum.id
           }
    end

    assert_differences([['GroupResponse.count', -1], ['Notification.count', -2]]) do
      delete group_response_path(GroupResponse.last)
    end
  end

  test 'should create and destroy comment with notifications' do
    # Both the argument publisher as the argument follower will receive a notification
    sign_in user

    assert_differences([['Comment.count', 1], ['Notification.count', 2]]) do
      post argument_comments_path(follow_argument.followable),
           comment: attributes_for(:comment)
    end

    assert_differences([['Comment.trashed_only.count', 1], ['Notification.count', -2]]) do
      delete destroy_argument_comment_path(follow_argument.followable, Comment.last)
    end
  end

  test 'should create and destroy blog_post with notifications' do
    Forum.first.page.update(owner_id: user.profile.id)
    sign_in user

    assert_differences([['BlogPost.count', 1], ['Notification.count', 1]]) do
      post project_blog_posts_path(follow_project.followable),
           blog_post: attributes_for(:blog_post)
    end

    assert_differences([['BlogPost.trashed_only.count', 1], ['Notification.count', -1]]) do
      delete blog_post_path(BlogPost.last)
    end
  end
end
