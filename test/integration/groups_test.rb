# frozen_string_literal: true

require 'test_helper'

class GroupsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:group) { create(:group, parent: argu) }
  let!(:granted_group) { create(:group, parent: argu) }
  let!(:gg_grant) do
    create(:grant,
           edge: freetown,
           group: granted_group,
           grant_set: GrantSet.participator)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user

    get new_iri(argu, :groups)

    assert_response :success
  end

  test 'user should not get settings' do
    sign_in user

    get settings_iri(group)

    assert_response :success
  end

  test 'user should not put update' do
    sign_in user

    put group, params: {group: {name: 'new_name'}}

    assert_not_authorized
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete group
    end

    assert_not_authorized
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(argu) }

  test 'moderator should not post create group' do
    sign_in moderator

    assert_difference('Group.count', 0) do
      post Group.collection_iri(root: argu),
           params: {
             group: {
               group_id: group.id,
               name: 'Test group'
             }
           }
    end
    assert_not_authorized
  end

  test 'moderator should not get new' do
    sign_in moderator

    get new_iri(argu, :groups)

    assert_response :success
  end

  test 'moderator should not get settings' do
    sign_in moderator

    get settings_iri(group)
    assert_response :success
  end

  test 'moderator should not delete destroy' do
    sign_in moderator

    assert_no_difference 'Group.count' do
      delete group
    end

    assert_response 403
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should post create group' do
    sign_in administrator

    assert_difference('Group.count' => 1, 'Grant.count' => 0) do
      post Group.collection_iri(root: argu),
           params: {
             group: {
               name: 'Test group',
               name_singular: 'Tester'
             }
           }
    end
    assert_response :created
  end

  test 'administrator should post create group with grant' do
    sign_in administrator

    assert_difference('Group.count' => 1, 'Grant.count' => 1) do
      post Group.collection_iri(root: argu),
           params: {
             group: {
               name: 'Test group',
               name_singular: 'Tester',
               grants_attributes: {
                 '0': {
                   grant_set_id: GrantSet.participator.id,
                   edge_id: argu.uuid
                 }
               }
             }
           }
    end
    assert_response :created
  end

  test 'administrator should get new' do
    sign_in administrator

    get new_iri(argu, :groups)

    assert_response 200
  end

  test 'administrator should show settings and all tabs' do
    sign_in administrator

    get settings_iri(granted_group)
    assert_group_settings_shown granted_group, :edit

    %i[members email_invite bearer_invite grants delete].each do |tab|
      get settings_iri(granted_group, tab: tab)
      assert_group_settings_shown granted_group, tab
    end
  end

  test 'administrator should delete destroy' do
    sign_in administrator

    assert_difference 'Group.count', -1 do
      delete group, params: {group: {confirmation_string: 'remove'}}
    end

    assert_response :success
  end

  test 'administrator should not delete destroy without confirmation' do
    sign_in administrator

    assert_difference 'Group.count', 0 do
      delete group
    end
  end

  test 'administrator should put update' do
    sign_in administrator

    put group,
        params: {
          group: {
            name: 'new_name',
            name_singular: 'new_singular',
            tab: 'general'
          }
        }

    assert_equal group.reload.name, 'new_name'
    assert_equal group.reload.name_singular, 'new_singular'
    assert_response :success
  end

  private

  # Asserts that the group is shown on a specific tab
  # @param [Group] group The group to be shown
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_group_settings_shown(group, tab = :general)
    assert_response 200
    expect_resource_type(NS.ontola[:MenuItem], iri: settings_iri(group, tab: tab))
  end
end
