# frozen_string_literal: true
require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  setup do
    @freetown = freetown
    @freetown_owner = freetown.edge.parent.owner.owner.profileable
    @group = create(:group, parent: @freetown.page.edge)
  end

  let!(:group) { create(:group, parent: freetown.page.edge) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not show new' do
    sign_in user

    get :new, params: {id: group, page_id: freetown.page}

    assert_not_authorized
  end

  test 'user should not show settings' do
    sign_in user

    get :settings, params: {id: group, page_id: freetown.page}

    assert_not_authorized
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete :destroy, params: {id: group}
    end

    assert_not_authorized
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(@freetown.page) }
  test 'manager should post create visible group' do
    sign_in manager

    post :create,
         params: {
           page_id: freetown.page,
           group: {
               group_id: group.id,
               name: 'Test group visible',
               visibilitiy: 'visible'
           }
         }

    assert true
  end

  test 'manager should show new' do
    sign_in manager

    get :new, params: {id: @group, page_id: @freetown.page}

    assert_response 200
  end

  test 'manager should show settings and some tabs' do
    sign_in manager

    get :settings, params: {id: @group, forum_id: @freetown}

    %i(general members invite).each do |tab|
      get :settings, params: {id: @group, forum_id: @freetown, tab: tab}
      assert_group_settings_shown @group, tab
    end

    assert_response 200
  end

  test 'manager should not delete destroy' do
    sign_in manager

    assert_no_difference 'Group.count' do
      delete :destroy, params: {id: @group}
    end

    assert_response 302
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should post create visible group' do
    sign_in @freetown_owner

    post :create,
         params: {
           page_id: freetown.page,
           group: {
               group_id: group.id,
               name: 'Test group visible',
               visibilitiy: 'visible'
           }
         }

    assert true

    # TODO: This test should assert a bit more things.
  end

  test 'owner should show new' do
    sign_in @freetown_owner

    get :new, params: {id: @group, page_id: @freetown.page}

    assert_response 200
  end

  test 'owner should show settings and all tabs' do
    sign_in @freetown_owner

    get :settings, params: {id: @group, forum_id: @freetown}

    %i(general members invite grants).each do |tab|
      get :settings, params: {id: @group, forum_id: @freetown, tab: tab}
      assert_group_settings_shown @group, tab
    end

    assert_response 200
  end

  test 'owner should delete destroy' do
    sign_in @freetown_owner

    assert_difference 'Group.count', -1 do
      delete :destroy, params: {id: @group}
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
