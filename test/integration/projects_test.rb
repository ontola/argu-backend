# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:subject) { create(:project, publisher: creator, parent: freetown.edge) }
  let(:unpublished) do
    create(:project,
           publisher: creator,
           parent: freetown.edge,
           edge_attributes: {argu_publication_attributes: {draft: true}})
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :freetown}) do
      user_types[:new].merge(
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :show)
    define_test(hash, :show, suffix: ' unpublished', options: {record: :unpublished}) do
      user_types[:show].merge(
        guest: exp_res(asserts: [assert_not_authorized]),
        spectator: exp_res(asserts: [assert_not_authorized]),
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :show, suffix: ' non-existent', options: {record: -1}) do
      {user: exp_res(response: 404)}
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('projects', 'create_success'),
      attributes: {
        happening_attributes: {happened_at: DateTime.current},
        edge_attributes: {argu_publication_attributes: {draft: true}}
      },
      differences: [['Project.unpublished', 1],
                    ['Activity.loggings', 1],
                    ['Notification', 0]]
    }
    define_test(hash, :create, suffix: ' draft', options: options) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
        user: exp_res(asserts: [assert_not_authorized], analytics: false),
        member: exp_res(asserts: [assert_not_authorized], analytics: false),
        manager: exp_res(response: 302, should: true, asserts: [assert_not_published]),
        super_admin: exp_res(response: 302, should: true, asserts: [assert_not_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_not_published])
      }
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('projects', 'create_success'),
      attributes: {happened_at: DateTime.current}
    }
    define_test(hash, :create, suffix: ' published', options: options) do
      {
        manager: exp_res(response: 302, should: true, asserts: [assert_is_published]),
        super_admin: exp_res(response: 302, should: true, asserts: [assert_is_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_is_published])
      }
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('projects', 'create_failed'),
      attributes: {title: 'Project', content: 'C'}
    }
    define_test(hash, :create, suffix: ' erroneous', options: options) do
      {manager: exp_res(response: 200, asserts: [assert_has_content, assert_has_title])}
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('projects', 'create_success'),
      attributes: {
        default_cover_photo_attributes: {
          content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :create, suffix: ' with cover_photo', options: options) do
      {manager: exp_res(response: 302, should: true, asserts: [assert_photo_identifier, assert_has_media_object])}
    end
    define_test(hash, :edit) do
      user_types[:edit].except(:creator)
    end
    define_test(hash, :update) do
      user_types[:update].except(:creator)
    end
    define_test(hash, :update, suffix: ' erroneous', options: {attributes: {title: 'Project', content: 'C'}}) do
      {manager: exp_res(response: 200, asserts: [assert_has_content, assert_has_title])}
    end
    options = {
      attributes: {
        default_cover_photo_attributes: {
          content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :update, suffix: ' with cover_photo', options: options) do
      {manager: exp_res(response: 302, should: true, asserts: [assert_photo_identifier, assert_has_media_object])}
    end
    define_test(hash, :destroy, options: {analytics: stats_opt('projects', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('projects', 'trash_success')})
  end
end
