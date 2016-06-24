# frozen_string_literal: true
require 'test_helper'

class BlogPostPublishingTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:project) do
    create(:project,
           :with_follower,
           argu_publication: build(:publication),
           parent: freetown)
  end

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

    post project_blog_posts_path(project_id: project,
                                 blog_post: attributes_for(:blog_post, forum: project.forum))
    assert_not_authorized
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(project) }

  test 'should post create draft blog_post' do
    sign_in moderator
    assert_not moderator.has_drafts?

    get project_path(project)
    assert_response 200

    get new_project_blog_post_path(project_id: project)
    assert_response 200

    assert_difference('Publication.count', 1) do
      post project_blog_posts_path(
        project_id: project,
        blog_post: attributes_for(:blog_post,
                                  forum: project.forum,
                                  argu_publication_attributes: {publish_type: :draft}))
      assert_response 302
    end

    follow_redirect!
    assert moderator.reload.has_drafts?
    assert_response 200
    assert_equal false, BlogPost.last.is_published?
    assert_equal 0, Notification.count
  end

  test 'should post create published blog_post' do
    sign_in moderator

    get project_path(project)
    assert_response 200

    get new_project_blog_post_path(project_id: project)
    assert_response 200

    post project_blog_posts_path(
      project_id: project,
      blog_post: attributes_for(:blog_post,
                                forum: project.forum,
                                happened_at: DateTime.current,
                                argu_publication_attributes: {publish_type: :direct}))
    assert_response 302

    # Notification for creator and follower of project
    assert_difference('Notification.count', 2) do
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end

    follow_redirect!
    assert_response 200
    assert_not moderator.reload.has_drafts?
    assert BlogPost.last.is_published?
  end

  test 'moderator post create scheduled blog_post' do
    sign_in moderator

    assert_difference('Publication.count', 1) do
      post project_blog_posts_path(
        project_id: project,
        blog_post: attributes_for(
          :blog_post,
          forum: project.forum,
          argu_publication_attributes: {
            publish_type: :schedule,
            published_at: 1.day.from_now
          }))
      assert_response 302
    end
  end

  test 'moderator should change schedule to draft' do
    sign_in moderator

    get project_path(project)
    assert_response 200

    get new_project_blog_post_path(project_id: project)
    assert_response 200

    post project_blog_posts_path(
      project_id: project,
      blog_post: attributes_for(:blog_post,
                                forum: project.forum,
                                argu_publication_attributes: {publish_type: :schedule,
                                                              published_at: 1.day.from_now}))
    assert_response 302

    patch blog_post_path(
      id: BlogPost.last.id,
      blog_post: {argu_publication_attributes: {publish_type: :draft}})
    assert_response 302

    Sidekiq::Testing.inline! do
      Publication.last.send(:reset)
    end

    follow_redirect!
    assert_response 200
    assert_equal false, BlogPost.last.is_published?
    assert_equal 0, Notification.count
  end
end
