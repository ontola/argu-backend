require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @holland, @holland_owner = create_forum_owner_pair({type: :populated_forum})
    @group = FactoryGirl.create(:group, forum: @holland)
  end

  let(:holland) { FactoryGirl.create(:forum, name: 'holland') }
  let!(:group) { FactoryGirl.create(:group, forum: holland) }

  ####################################
  # For users
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should not show new' do
    sign_in user

    get :new, id: group, forum_id: holland

    assert_redirected_to root_path
    assert assigns(:forum)
  end

  test 'should not show edit' do
    sign_in user

    get :edit, id: group, forum_id: holland

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
  # For owners
  ####################################

  test 'should show new' do
    sign_in @holland_owner

    get :new, id: @group, forum_id: @holland

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should show edit' do
    sign_in @holland_owner

    get :edit, id: @group, forum_id: @holland

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should delete destroy!' do
    sign_in @holland_owner

    assert_difference 'Group.count', -1 do
      delete :destroy!, id: @group
    end

    assert_response 303
    assert assigns(:forum)
    assert assigns(:group)
  end
end
