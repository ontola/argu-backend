require 'test_helper'

# @TODO: add correct fixtures and implement tests
class GroupResponsesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:freetown) { create(:forum) }
  let(:motion) do
    create(:motion,
           forum: freetown)
  end
  let(:group) do
    create(:group,
           :discussion,
           forum: freetown)
  end
  let(:group_response) do
    create(:group_response,
           profile: group_member.profile,
           group: group,
           motion: motion,
           forum: freetown)
  end
  let(:visible_group) do
    create(:group,
           :visible,
           forum: freetown)
  end
  let(:hidden_group) do
    create(:group,
           :hidden,
           forum: freetown)
  end

  ####################################
  # As Guest
  ####################################
  test 'should not get edit when not logged in' do
    get :edit,
        id: group_response

    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user

    get :new,
        motion_id: motion,
        group_id: group,
        side: :pro

    assert_not_a_member
  end

  test 'user should not get edit' do
    sign_in user

    get :edit,
        id: group_response

    assert_not_a_member
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference('GroupResponse.count') do
      post :create,
           motion_id: motion,
           group_id: group,
           group_response: attributes_for(:group_response,
                                          forum: freetown)
    end

    assert_not_a_member
  end

  test 'user should not put update' do
    sign_in user

    assert_no_difference('group_response.updated_at') do
      put :update,
          id: group_response
    end

    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not get new' do
    sign_in member

    get :new,
        motion_id: motion,
        group_id: group,
        side: :pro

    assert_not_authorized
  end

  test 'member should not get edit' do
    sign_in member

    get :edit,
        id: group_response

    assert_not_authorized
  end

  test 'member should not post create' do
    sign_in member

    assert_no_difference('GroupResponse.count') do
      post :create,
           motion_id: motion,
           group_id: group,
           group_response: attributes_for(:group_response,
                                          forum: freetown)
    end

    assert_not_authorized
  end

  test 'member should not put update' do
    sign_in member

    assert_no_difference('group_response.updated_at') do
      put :update,
          id: group_response
    end

    assert_not_authorized
  end

  ####################################
  # As Group Member
  ####################################
  let(:group_member) { create_group_member(group) }

  test 'group member should get new' do
    sign_in group_member

    get :new,
        motion_id: motion,
        group_id: group,
        side: :pro

    assert_response 200
  end

  test 'group member should get edit' do
    sign_in group_member

    get :edit,
        id: group_response

    assert_response 200
  end

  test 'group member should post create' do
    sign_in group_member

    assert_difference('GroupResponse.count', 1) do
      post :create,
           motion_id: motion,
           group_id: group,
           group_response: attributes_for(:group_response,
                                          forum: freetown)
    end

    assert_redirected_to motion
  end

  test 'group member should put update' do
    sign_in group_member

    put :update,
        id: group_response,
        group_response: {
          text: 'new text'
        }

    assert_redirected_to motion
    assert_equal 'new text', assigns(:resource).text
  end

  test 'group member should delete destroy own response' do
    sign_in group_member

    group_response # trigger
    assert_difference('GroupResponse.count', -1) do
      delete :destroy,
             id: group_response
    end

    assert_redirected_to motion
  end

  test "group member should not delete destroy others' response" do
    sign_in group_member

    group_response = create(:group_response,
                            motion: motion,
                            group: group,
                            forum: freetown)
    assert_no_difference('GroupResponse.count') do
      delete :destroy,
             id: group_response
    end

    assert_not_authorized
  end

  ## Visible groups ##
  let(:visible_group_member) { create_group_member(visible_group) }

  test 'group member should not get new on visible' do
    sign_in visible_group_member

    get :new,
        motion_id: motion,
        group_id: visible_group,
        side: :pro

    assert_response 302
  end

  test 'group member should not post create on visible' do
    sign_in visible_group_member

    assert_no_difference('GroupResponse.count') do
      post :create,
           motion_id: motion,
           group_id: visible_group,
           group_response: attributes_for(:group_response,
                                          forum: freetown)
    end

    assert_response 302
  end

  ## hidden groups ##
  let(:hidden_group_member) { create_group_member(hidden_group) }

  test 'group member should not get new on hidden' do
    sign_in hidden_group_member

    get :new,
        motion_id: motion,
        group_id: hidden_group,
        side: :pro

    assert_not_authorized
  end

  test 'group member should not post create on hidden' do
    sign_in hidden_group_member

    assert_no_difference('GroupResponse.count') do
      post :create,
           motion_id: motion,
           group_id: hidden_group,
           group_response: attributes_for(:group_response,
                                          forum: freetown)
    end

    assert_not_authorized
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test "manager should delete destroy others' response" do
    sign_in manager

    group_response # trigger
    assert_difference('GroupResponse.count', -1) do
      delete :destroy,
             id: group_response
    end

    assert_redirected_to motion
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test "owner should delete destroy others' response" do
    sign_in owner

    group_response # trigger
    assert_difference('GroupResponse.count', -1) do
      delete :destroy,
             id: group_response
    end

    assert_redirected_to motion
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test "staff should delete destroy others' response" do
    sign_in staff

    group_response # trigger
    assert_difference('GroupResponse.count', -1) do
      delete :destroy,
             id: group_response
    end

    assert_redirected_to motion
  end
end
