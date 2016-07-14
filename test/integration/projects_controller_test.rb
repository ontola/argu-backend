# frozen_string_literal: true
require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  let!(:owner) { argu.owner.profileable }
  let!(:page) { argu }

  let!(:moderator) { create_moderator(freetown) }
  let!(:subject) do
    p = create(:project,
               argu_publication: build(:publication),
               parent: freetown.edge)
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
  end
  let(:unpublished) do
    p = create(:project, parent: freetown.edge)
    create(:stepup,
           record: p,
           forum: freetown,
           moderator: moderator)
    p
  end
  let!(:trashed_subject) do
    create(:project,
           argu_publication: build(:publication),
           trashed_at: Time.current,
           parent: freetown.edge)
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    general_new
  end

  test 'guest should get show published' do
    general_show
  end

  test 'guest should not get show unpublished' do
    general_show 302, unpublished
    assert_not_authorized
  end

  test 'guest should not post create' do
    general_create_draft
  end

  test 'guest should not get edit' do
    general_edit
  end

  test 'guest should not patch update' do
    general_update
  end

  test 'guest should not delete destroy trash' do
    general_trash
  end

  test 'guest should not delete destroy' do
    general_destroy
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user
    general_new 403
    assert_not_a_member
  end

  test 'user should get show' do
    sign_in user
    general_show
  end

  test 'user should not get show unpublished' do
    sign_in user
    general_show 302, unpublished
    assert_not_authorized
  end

  test 'user should not post create' do
    sign_in user
    general_create_draft 403
    assert_not_a_member
  end

  test 'user should not get edit' do
    sign_in user
    general_edit 403
    assert_not_a_member
  end

  test 'user should not patch update' do
    sign_in user
    general_update 403
    assert_not_a_member
  end

  test 'user should not delete destroy trash' do
    sign_in user
    general_update 403
    assert_not_a_member
  end

  test 'user should not delete destroy' do
    sign_in user
    general_destroy 403
    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not get new' do
    sign_in member
    general_new
  end

  test 'member should get show' do
    sign_in member
    general_show
  end

  test 'member should not get show unpublished' do
    sign_in member
    general_show 302, unpublished
    assert_not_authorized
  end

  test 'member should not post create' do
    sign_in member
    general_create_draft
  end

  test 'member should not get edit' do
    sign_in member
    general_edit
  end

  test 'member should not patch update' do
    sign_in member
    general_update
  end

  test 'member should not delete destroy trash' do
    sign_in member
    general_trash
  end

  test 'member should not delete destroy' do
    sign_in member
    general_destroy
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
  let(:netdem_rule_new) do
    create(:rule,
           context: freetown,
           model_type: 'Project',
           action: 'new?',
           role: netdem.identifier,
           permit: true)
  end
  let(:netdem_rule_create) do
    create(:rule,
           context: freetown,
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
    [netdem_membership, discussion_membership, netdem_rule_new, netdem_rule_create]
  end

  test 'moderator should get new project' do
    netdem_rules
    sign_in netdem_member

    general_new(200)
  end

  test 'moderator should post create project draft' do
    netdem_rules
    sign_in netdem_member
    # Test post create
    # Test that the proper stepup is generated
    general_create_draft 302,
                         [['Project.count', 1],
                          ['Project.published.count', 0],
                          ['Stepup.count', 1],
                          ['Phase.count', 1]]
  end

  test 'moderator should post create project publish' do
    netdem_rules
    sign_in netdem_member
    # Test post create
    # Test that the proper stepup is generated
    general_create_publish 302,
                           [['Project.count', 1],
                            ['Project.published.count', 1],
                            ['Stepup.count', 1],
                            ['Phase.count', 1]]
  end

  test 'moderator should not cause leaking access' do
    netdem_rules
    sign_in discussion_member

    general_new
    general_create_draft
  end

  ####################################
  # As Moderator
  ####################################
  test 'moderator should get show' do
    sign_in moderator
    general_show
  end

  test 'moderator should get show unpublished' do
    sign_in moderator

    general_show 200, unpublished
  end

  test 'moderator should get edit' do
    sign_in moderator
    general_edit 200
  end

  test 'moderator should patch update' do
    sign_in moderator
    general_update 302, true
  end

  test 'moderator should delete destroy trash' do
    sign_in moderator
    general_trash 302, 1
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager freetown }
  test 'manager should get new' do
    sign_in manager
    general_new 200
  end

  test 'manager should get show' do
    sign_in manager
    general_show 200
  end

  test 'manager should get show unpublished' do
    sign_in manager
    general_show 200, unpublished
  end

  test 'manager should post create draft' do
    sign_in manager
    general_create_draft 302,
                         [['Project.count', 1],
                          ['Project.published.count', 0],
                          ['Stepup.count', 1],
                          ['Phase.count', 1]]
  end

  test 'manager should post create publish' do
    sign_in manager
    general_create_publish 302,
                           [['Project.count', 1],
                            ['Project.published.count', 1],
                            ['Stepup.count', 1],
                            ['Phase.count', 1]]
  end

  test 'manager should get edit' do
    sign_in manager
    general_edit 200
  end

  test 'manager should patch update' do
    sign_in manager
    general_update 302, true
  end

  test 'manager should delete destroy trash' do
    sign_in manager
    general_trash 302, 1
  end

  test 'manager should delete destroy' do
    sign_in manager
    general_destroy 302, -1
  end

  ####################################
  # As Owner
  ####################################
  test 'owner should get new' do
    sign_in owner
    general_new 200
  end

  test 'owner should get show' do
    sign_in owner
    general_show
  end

  test 'owner should get show unpublished' do
    sign_in owner
    general_show 200, unpublished
  end

  test 'owner should post create draft' do
    sign_in owner
    general_create_draft 302,
                         [['Project.count', 1],
                          ['Project.published.count', 0],
                          ['Stepup.count', 1],
                          ['Phase.count', 1]]
  end

  test 'owner should post create publish' do
    sign_in owner
    general_create_publish 302,
                           [['Project.count', 1],
                            ['Project.published.count', 1],
                            ['Stepup.count', 1],
                            ['Phase.count', 1]]
  end

  test 'owner should get edit' do
    sign_in owner
    general_edit 200
  end

  test 'owner should patch update' do
    sign_in owner
    general_update 302, true
  end

  test 'owner should delete destroy trash' do
    sign_in owner
    general_destroy 302, -1
  end

  test 'owner should delete destroy' do
    sign_in owner
    general_destroy 302, -1
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get new' do
    sign_in staff
    general_new 200
  end

  test 'staff should get show' do
    sign_in staff
    general_show 200
  end

  test 'staff should get show unpublished' do
    sign_in staff
    general_show 200, unpublished
  end

  test 'staff should post create draft' do
    sign_in staff
    general_create_draft 302,
                         [['Project.count', 1],
                          ['Project.published.count', 0],
                          ['Stepup.count', 1],
                          ['Phase.count', 1]]
  end

  test 'staff should post create publish' do
    sign_in staff
    general_create_publish 302,
                           [['Project.count', 1],
                            ['Project.published.count', 1],
                            ['Stepup.count', 1],
                            ['Phase.count', 1]]
  end

  test 'staff should get edit' do
    sign_in staff
    general_edit 200
  end

  test 'staff should patch update' do
    sign_in staff
    general_update 302, true
  end

  test 'staff should delete destroy trash' do
    sign_in staff
    general_trash 302, 1
  end

  test 'staff should delete destroy' do
    sign_in staff
    general_destroy 302, -1
  end

  private

  def general_new(response = 302)
    get new_forum_project_path(freetown)

    assert_response response
  end

  def general_show(response = 200, record = subject)
    get project_path(record)

    assert_response response
  end

  def general_create_draft(response = 302, differences = [['Project.count', 0],
                                                          ['Stepup.count', 0],
                                                          ['Phase.count', 0],
                                                          ['Activity.count', 0]])
    assert_differences(differences) do
      post forum_projects_path(freetown),
           project: attributes_for(:project,
                                   argu_publication_attributes: {publish_type: :draft},
                                   stepups_attributes: {'12321' => {moderator: moderator.url}},
                                   phases_attributes: {'12321' => attributes_for(:phase)})
    end

    assert_response response
  end

  def general_create_publish(response = 302, differences = [['Project.count', 0],
                                                            ['Stepup.count', 0],
                                                            ['Phase.count', 0],
                                                            ['Activity.count', 0]])
    assert_differences(differences) do
      post forum_projects_path(freetown),
           project: attributes_for(:project,
                                   argu_publication_attributes: {publish_type: :direct},
                                   stepups_attributes: {'12321' => {moderator: moderator.url}},
                                   phases_attributes: {'12321' => attributes_for(:phase)})
      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end

    assert_response response
  end

  def general_edit(response = 302)
    get edit_project_path(subject)

    assert_response response
  end

  def general_update(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)

    assert_difference('Activity.count', changed ? 1 : 0) do
      patch project_path(subject),
            project: attributes_for(:project)
    end

    assert_response response
    if assigns(:update_service).try(:resource).present?
      ch_method.call subject
                       .updated_at
                       .iso8601(6),
                     assigns(:update_service)
                       .try(:resource)
                       .try(:updated_at)
                       .try(:iso8601, 6)
    elsif changed
      assert false, "can't be changed"
    end
  end

  def general_trash(response = 302, difference = 0)
    assert_differences([['Project.trashed_only.count', difference],
                        ['Activity.count', difference.abs]]) do
      delete project_path(subject)
    end

    assert_response response
  end

  def general_destroy(response = 302, difference = 0)
    assert_differences([['Project.count', difference],
                        ['Activity.count', difference.abs]]) do
      delete project_path(subject,
                          destroy: true)
    end

    assert_response response
  end
end
