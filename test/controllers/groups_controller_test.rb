require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @freetown, @freetown_owner = create_forum_owner_pair
    @group = FactoryGirl.create(:group, forum: @freetown)
  end

  let(:freetown) { FactoryGirl.create(:forum, name: 'freetown') }
  let!(:group) { FactoryGirl.create(:group, forum: freetown) }

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should not show new' do
    sign_in user

    get :new, id: group, forum_id: freetown

    assert_redirected_to root_path
    assert assigns(:forum)
  end

  test 'should not show edit' do
    sign_in user

    get :edit, id: group, forum_id: freetown

    assert_redirected_to root_path
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should not delete destroy' do
    sign_in user

    assert_no_difference 'Group.count' do
      delete :destroy!, id: group
    end

    assert_redirected_to root_path
  end

  ####################################
  # As Owner
  ####################################

  test 'should show new' do
    sign_in @freetown_owner

    get :new, id: @group, forum_id: @freetown

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should show edit' do
    sign_in @freetown_owner

    get :edit, id: @group, forum_id: @freetown

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should delete destroy!' do
    sign_in @freetown_owner

    assert_difference 'Group.count', -1 do
      delete :destroy!, id: @group
    end

    assert_response 303
    assert assigns(:forum)
    assert assigns(:group)
  end
end
