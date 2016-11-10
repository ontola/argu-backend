# frozen_string_literal: true
require 'test_helper'

class GroupsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:group) { create(:group, parent: freetown.page.edge) }

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

  test 'user should not get show' do
    sign_in user

    get group_path(group)

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
  # As Member
  ####################################
  let(:member) { create(:group_membership, parent: group.edge).member.profileable }

  test 'member should get show' do
    sign_in member

    get group_path(group)

    assert_redirected_to page_path(group.page)
    follow_redirect!
    refute_have_tag response.body,
                    '.alert-wrapper .alert',
                    '<div class="alert-close"><span class="fa fa-close"></span></div>'\
                    "You are successfully added to the group '#{group.display_name}'"
  end

  test 'member should get show with welcome message' do
    sign_in member

    get group_path(group, welcome: 'true')

    assert_redirected_to page_path(group.page)
    follow_redirect!
    assert_have_tag response.body,
                    '.alert-wrapper .alert',
                    '<div class="alert-close"><span class="fa fa-close"></span></div>'\
                    "You are successfully added to the group '#{group.display_name}'"
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(@freetown.page) }

  test 'manager should post create visible group' do
    sign_in manager

    assert_difference('Group.count', 1) do
      post page_groups_path(freetown.page),
           params: {
             group: {
               group_id: group.id,
               name: 'Test group visible',
               visibilitiy: 'visible'
             }
           }
    end
    assert_redirected_to settings_page_path(freetown.page, tab: :groups)
  end

  test 'manager should get new' do
    sign_in manager

    get new_page_group_path(@freetown.page)

    assert_response 200
  end

  test 'manager should get settings and some tabs' do
    sign_in manager

    get settings_group_path(@group)
    assert_response 200

    %i(general members invite).each do |tab|
      get settings_group_path(@group, tab: tab)
      assert_group_settings_shown(@group, tab)
    end
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

  test 'super_admin should post create visible group' do
    sign_in super_admin

    assert_difference('Group.count', 1) do
      post page_groups_path(freetown.page),
           params: {
             group: {
               group_id: group.id,
               name: 'Test group visible',
               visibilitiy: 'visible'
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
