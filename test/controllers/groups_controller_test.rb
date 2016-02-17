require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @freetown, @freetown_owner = create_forum_owner_pair
    @group = create(:group, forum: @freetown)
  end

  let(:freetown) { create(:forum, name: 'freetown') }
  let!(:group) { create(:group, forum: freetown) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not show new' do
    sign_in user

    get :new, id: group, forum_id: freetown

    assert_redirected_to forum_path(freetown)
    assert assigns(:forum)
  end

  test 'user should not show edit' do
    sign_in user

    get :edit, id: group, forum_id: freetown

    assert_redirected_to forum_path(freetown)
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'user should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete :destroy, id: group
    end

    assert_redirected_to forum_path(freetown)
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should post create visible group' do
    sign_in @freetown_owner

    post :create,
         forum_id: freetown,
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

    get :new, id: @group, forum_id: @freetown

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'owner should show edit' do
    sign_in @freetown_owner

    get :edit, id: @group, forum_id: @freetown

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'owner should delete destroy' do
    sign_in @freetown_owner

    assert_difference 'Group.count', -1 do
      delete :destroy, id: @group
    end

    assert_response 303
    assert assigns(:forum)
    assert assigns(:group)
  end
end
