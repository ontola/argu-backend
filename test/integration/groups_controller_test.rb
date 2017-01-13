# frozen_string_literal: true
require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
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

  test 'user should not show new' do
    sign_in user

    get new_page_group_path(freetown.page)

    assert_not_authorized
  end

  test 'user should not show settings' do
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

  test 'manager should show new' do
    sign_in manager

    get new_page_group_path(@freetown.page)

    assert_response 200
  end

  test 'manager should show settings and some tabs' do
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
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test 'owner should post create visible group' do
    sign_in owner

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

  test 'owner should show new' do
    sign_in owner

    get new_page_group_path(@freetown.page)

    assert_response 200
  end

  test 'owner should show settings and all tabs' do
    sign_in owner

    get settings_group_path(@group)
    assert_response 200

    %i(general members invite grants).each do |tab|
      get settings_group_path(@group, tab: tab)
      assert_group_settings_shown @group, tab
    end
  end

  test 'owner should delete destroy' do
    sign_in owner

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
