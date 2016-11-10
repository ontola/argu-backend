# frozen_string_literal: true
require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:subject) do
    p = create(:project, publisher: creator, parent: freetown.edge)
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
  end
  let(:unpublished) do
    p = create(:project,
               publisher: creator,
               parent: freetown.edge,
               edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
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
        happened_at: DateTime.current,
        edge_attributes: {argu_publication_attributes: {publish_type: :draft}}
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
        moderator: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        manager: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        super_admin: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_has_drafts, assert_not_published])
      }
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('projects', 'create_success'),
      attributes: {happened_at: DateTime.current}
    }
    define_test(hash, :create, suffix: ' published', options: options) do
      {
        moderator: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        manager: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        super_admin: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published]),
        staff: exp_res(response: 302, should: true, asserts: [assert_no_drafts, assert_is_published])
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
      user_types[:edit].except(:creator).merge(moderator: exp_res(should: true, response: 200))
    end
    define_test(hash, :update) do
      user_types[:update].except(:creator).merge(moderator: exp_res(response: 302, should: true))
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
    define_test(hash, :trash, options: {analytics: stats_opt('projects', 'trash_success')}) do
      user_types[:trash].merge(moderator: exp_res(response: 302, should: true))
    end
  end

  ####################################
  # As NetDem member
  # The following tests are specific to the use case of NetDem
  ####################################
  let(:netdem) { create(:group, name: 'Netwerk Democratie', parent: freetown.page.edge) }
  let(:netdem_member) { create_member(freetown) }
  let(:netdem_membership) do
    create(:group_membership,
           member: netdem_member.profile,
           parent: netdem.edge)
  end
  let(:netdem_rule_create) do
    create(:rule,
           branch: freetown.edge,
           model_type: 'Project',
           action: 'create?',
           role: netdem.identifier,
           permit: true)
  end
  let(:discussion_group) { create(:group, name: 'Politieke Partijen', parent: freetown.page.edge) }
  let(:discussion_member) { create_member(freetown) }
  let(:discussion_membership) do
    create(:group_membership,
           member: discussion_member.profile,
           parent: discussion_group.edge)
  end
  def netdem_rules
    [netdem_membership, discussion_membership, netdem_rule_create]
  end

  test 'moderator should get new project' do
    netdem_rules
    sign_in netdem_member

    general_new(results: {response: 200}, parent: :freetown)
  end

  test 'moderator should post create project draft' do
    netdem_rules
    sign_in netdem_member
    moderator.shortname.update(shortname: 'moderator_name')
    # Test post create
    # Test that the proper stepup is generated
    general_create(results: {response: 302, should: true},
                   parent: :freetown,
                   analytics: stats_opt('projects', 'create_success'),
                   attributes: attributes_for(
                     :project,
                     edge_attributes: {argu_publication_attributes: {publish_type: :draft}},
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 1],
                                 ['Project.published', 0],
                                 ['Stepup', 1],
                                 ['Phase', 1]])
  end

  test 'moderator should post create project publish' do
    netdem_rules
    sign_in netdem_member
    moderator.shortname.update(shortname: 'moderator_name')
    # Test post create
    # Test that the proper stepup is generated
    general_create(results: {response: 302, should: true},
                   parent: :freetown,
                   analytics: stats_opt('projects', 'create_success'),
                   attributes: attributes_for(
                     :project,
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 1],
                                 ['Project.published', 1],
                                 ['Stepup', 1],
                                 ['Phase', 1]])
  end

  test 'moderator should not cause leaking access' do
    netdem_rules
    sign_in discussion_member

    moderator.shortname.update(shortname: 'moderator_name')
    general_new(results: {response: 403}, parent: :freetown)
    general_create(results: {response: 403, should: false},
                   parent: :freetown,
                   attributes: attributes_for(
                     :project,
                     edge_attributes: {argu_publication_attributes: {publish_type: :draft}},
                     stepups_attributes: {'12321' => {moderator: 'moderator_name'}},
                     phases_attributes: {'12321' => attributes_for(:phase)}
                   ),
                   differences: [['Project', 0],
                                 ['Stepup', 0],
                                 ['Phase', 0]])
  end
end
