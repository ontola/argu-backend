# frozen_string_literal: true
require 'test_helper'

class BlogPostsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:project) do
    create(:project,
           :with_follower,
           parent: freetown.edge)
  end
  let(:subject) do
    create(:blog_post,
           happening_attributes: {happened_at: DateTime.current},
           publisher: creator,
           parent: project.edge)
  end
  let(:trashed_subject) do
    create(:blog_post,
           happening_attributes: {happened_at: DateTime.current},
           trashed_at: Time.current,
           parent: project.edge)
  end
  let(:scheduled) do
    create(:blog_post,
           edge_attributes: {argu_publication_attributes: {publish_type: 'schedule', published_at: 1.day.from_now}},
           happening_attributes: {happened_at: DateTime.current},
           parent: project.edge)
  end

  def self.assert_job_canceled
    'PublicationsWorker.cancelled?(Publication.last.job_id)'
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :project}) do
      user_types[:new].merge(
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :show)
    define_test(hash, :show, suffix: ' non-existent', options: {record: 'none'}) do
      {user: exp_res(response: 404)}
    end
    define_test(hash, :show, suffix: ' unpublished', options: {record: :scheduled}) do
      user_types[:show].merge(
        guest: exp_res(asserts: [assert_not_authorized]),
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized])
      )
    end
    options = {
      parent: :project,
      analytics: stats_opt('blog_posts', 'create_success'),
      attributes: {
        happening_attributes: {happened_at: DateTime.current},
        edge_attributes: {argu_publication_attributes: {publish_type: :draft}}
      },
      differences: [['BlogPost.unpublished', 1],
                    ['Activity.loggings', 1],
                    ['Notification', 0]]
    }
    define_test(hash, :create, suffix: ' draft', options: options) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
        user: exp_res(analytics: false, asserts: [assert_not_authorized]),
        member: exp_res(analytics: false, asserts: [assert_not_authorized]),
        moderator: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        manager: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        owner: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published])
      }
    end
    options = {
      parent: :project,
      analytics: stats_opt('blog_posts', 'create_success'),
      attributes: {happening_attributes: {happened_at: DateTime.current}}
    }
    define_test(hash, :create, suffix: ' published', options: options) do
      {
        moderator: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        manager: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        owner: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published])
      }
    end
    options = {
      parent: :project,
      analytics: stats_opt('blog_posts', 'create_failed'),
      attributes: {title: 'BlogPost', content: 'C'}
    }
    define_test(hash, :create, suffix: ' erroneous', options: options) do
      {manager: exp_res(response: 200, asserts: [assert_has_title, assert_has_content])}
    end
    define_test(hash, :edit, user_types: user_types[:edit].except(:creator))
    define_test(hash, :update, user_types: user_types[:update].except(:creator))
    define_test(hash, :update, suffix: ' erroneous', options: {attributes: {title: 'BlogPost', content: 'C'}}) do
      {manager: exp_res(response: 200, asserts: [assert_has_title, assert_has_content])}
    end
    options = {
      record: :scheduled,
      attributes: {edge_attributes: {argu_publication_attributes: {publish_type: :draft}}}
    }
    define_test(hash, :update, suffix: ' cancel schedule', options: options) do
      {manager: exp_res(response: 302, should: true, asserts: [assert_job_canceled])}
    end
    define_test(hash, :destroy, options: {analytics: stats_opt('blog_posts', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('blog_posts', 'trash_success')}) do
      user_types[:trash].merge(moderator: exp_res(response: 302, should: true))
    end
  end
end
