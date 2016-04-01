require 'test_helper'

class AccessTokenSignupTest < ActionDispatch::IntegrationTest
  let(:freetown) { create(:forum) }
  let(:project) { create(:project, :published, forum: freetown) }

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(project.forum) }

  test 'should not post create blog_post' do
    sign_in member

    get project_path(project)
    assert_response 200

    get new_project_blog_post_path(project_id: project)
    assert_not_authorized

    post project_blog_posts_path(
           project_id: project,
           blog_post: attributes_for(:blog_post))
    assert_not_authorized
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(project) }

  test 'should post create blog_post' do
    sign_in moderator

    get project_path(project)
    assert_response 200

    get new_project_blog_post_path(project_id: project)
    assert_response 200

    post project_blog_posts_path(
           project_id: project,
           blog_post: attributes_for(:blog_post))
    assert_response 302

    follow_redirect!
    assert_response 200
  end
end
