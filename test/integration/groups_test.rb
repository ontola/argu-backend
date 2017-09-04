# frozen_string_literal: true

require 'test_helper'

class GroupsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:group) { create(:group, parent: freetown.page.edge) }
  let!(:granted_group) { create(:group, parent: freetown.page.edge) }
  let!(:gg_grant) do
    create(:grant,
           edge: freetown.edge,
           group: granted_group,
           role: :member)
  end

  setup do
    @freetown = freetown
    @group = create(:group, parent: @freetown.page.edge)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user

    get new_page_group_path(freetown.page)

    assert_not_authorized
  end

  test 'user should not get settings' do
    sign_in user

    get settings_group_path(group)

    assert_not_authorized
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete group_path(group)
    end

    assert_not_authorized
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(@freetown.page) }

  test 'manager should not post create group' do
    sign_in manager

    assert_difference('Group.count', 0) do
      post page_groups_path(freetown.page),
           params: {
             group: {
               group_id: group.id,
               name: 'Test group'
             }
           }
    end
    assert_not_authorized
  end

  test 'manager should not get new' do
    sign_in manager

    get new_page_group_path(@freetown.page)

    assert_not_authorized
  end

  test 'manager should not get settings and some tabs' do
    sign_in manager

    get settings_group_path(@group)
    assert_not_authorized
  end

  test 'manager should not delete destroy' do
    sign_in manager

    assert_no_difference 'Group.count' do
      delete group_path(@group)
    end

    assert_response 403
  end

  ####################################
  # As Admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  test 'super_admin should post create group' do
    sign_in super_admin

    assert_differences([['Group.count', 1], ['Grant.count', 0]]) do
      post page_groups_path(freetown.page),
           params: {
             group: {
               name: 'Test group'
             }
           }
    end
    assert_redirected_to settings_page_path(freetown.page, tab: :groups)
  end

  test 'super_admin should post create group with grant' do
    sign_in super_admin

    assert_differences([['Group.count', 1], ['Grant.count', 1]]) do
      post page_groups_path(freetown.page),
           params: {
             group: {
               name: 'Test group',
               grants_attributes: {
                 '0': {
                   role: 'member',
                   edge_id: freetown.page.edge.id
                 }
               }
             }
           }
    end
    assert_redirected_to settings_page_path(freetown.page, tab: :groups)
  end

  test 'super_admin should get new' do
    sign_in super_admin

    get new_page_group_path(@freetown.page)

    assert_response 200
  end

  test 'super_admin should show settings and all tabs' do
    sign_in super_admin

    get settings_group_path(@group)
    assert_response 200

    %i(general members invite grants).each do |tab|
      get settings_group_path(@group, tab: tab)
      assert_group_settings_shown @group, tab
    end
  end

  test 'super_admin should delete destroy' do
    sign_in super_admin

    assert_difference 'Group.count', -1 do
      delete group_path(@group)
    end

    assert_response 303
  end

  private

  # Asserts that the group is shown on a specific tab
  # @param [Group] group The group to be shown
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_group_settings_shown(group, tab = :general)
    assert_response 200
    assert_have_tag response.body,
                    '.tabs-container li:first-child span.icon-left',
                    group.page.display_name
    assert_have_tag response.body,
                    '.tabs-container li:nth-child(2) span.icon-left',
                    I18n.t('pages.settings.title')
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    I18n.t("groups.settings.menu.#{tab}")
  end
end
