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

    get :new, id: group, page_id: freetown.page

    assert_not_authorized
  end

  test 'user should not show edit' do
    sign_in user

    get :edit, id: group, page_id: freetown.page

    assert_not_authorized
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete :destroy, id: group
    end

    assert_not_authorized
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should post create visible group' do
    sign_in @freetown_owner

    post :create,
         page_id: freetown.page,
         group: {
             group_id: group.id,
             name: 'Test group visible',
             visibilitiy: 'visible'
         }

    assert true

    # TODO: This test should assert a bit more things.
  end

  test 'owner should show new' do
    sign_in @freetown_owner

    get :new, id: @group, page_id: @freetown.page

    assert_response 200
  end

  test 'owner should show edit' do
    sign_in @freetown_owner

    get :edit, id: @group, forum_id: @freetown

    assert_response 200
  end

  test 'owner should delete destroy' do
    sign_in @freetown_owner

    assert_difference 'Group.count', -1 do
      delete :destroy, id: @group
    end

    assert_response 303
  end
end
