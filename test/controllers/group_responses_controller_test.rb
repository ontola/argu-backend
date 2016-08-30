# frozen_string_literal: true
require 'test_helper'

# @TODO: add correct fixtures and implement tests
class GroupResponsesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:group) do
    create(:group, visibility: :discussion, parent: freetown.page.edge)
  end
  let(:group_response) do
    create(:group_response,
           creator: group_member.profile,
           group: group,
           parent: motion.edge)
  end
  let(:visible_group) do
    create(:group, visibility: :visible, parent: freetown.page.edge)
  end
  let(:hidden_group) do
    create(:group, visibility: :hidden, parent: freetown.page.edge)
  end

  ####################################
  # As Guest
  ####################################
  test 'should not get edit when not logged in' do
    get :edit,
        params: {id: group_response}

    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user

    get :new,
        params: {
          motion_id: motion,
          group_id: group,
          side: :pro
        }

    assert_not_a_member
  end

  test 'user should not get edit' do
    sign_in user

    get :edit,
        params: {id: group_response}

    assert_not_a_member
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference('GroupResponse.count') do
      post :create,
           params: {
             motion_id: motion,
             group_id: group,
             group_response: attributes_for(:group_response,
                                            parent: freetown.edge)
           }
    end

    assert_not_a_member
  end

  test 'user should not put update' do
    sign_in user

    assert_no_difference('group_response.updated_at') do
      put :update,
          params: {id: group_response}
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
        params: {
          motion_id: motion,
          group_id: group,
          side: :pro
        }

    assert_not_authorized
  end

  test 'member should not get edit' do
    sign_in member

    get :edit,
        params: {id: group_response}

    assert_not_authorized
  end

  test 'member should not post create' do
    sign_in member

    assert_no_difference('GroupResponse.count') do
      post :create,
           params: {
             motion_id: motion,
             group_id: group,
             group_response: attributes_for(:group_response,
                                            parent: freetown.edge)
           }
    end

    assert_not_authorized
  end

  test 'member should not put update' do
    sign_in member

    assert_no_difference('group_response.updated_at') do
      put :update,
          params: {
            id: group_response,
            group_response: {
                text: 'new text'
            }
          }
    end

    assert_not_authorized
  end

  ####################################
  # As Group Member
  ####################################
  let(:group_member) { create_group_member(group, create_member(freetown)) }

  test 'group member should get new' do
    sign_in group_member

    get :new,
        params: {
          motion_id: motion,
          group_id: group,
          side: :pro
        }

    assert_response 200
  end

  test 'group member should get edit' do
    sign_in group_member

    get :edit,
        params: {id: group_response}

    assert_response 200
  end

  test 'group member should post create' do
    sign_in group_member

    assert_difference('GroupResponse.count', 1) do
      post :create,
           params: {
             motion_id: motion,
             group_id: group,
             group_response: attributes_for(:group_response,
                                            parent: freetown.edge)
           }
    end

    assert_redirected_to motion
  end

  test 'group member should put update' do
    sign_in group_member

    put :update,
        params: {
          id: group_response,
          group_response: {
            text: 'new text'
          }
        }

    assert_redirected_to motion
    assert_equal 'new text', assigns(:resource).text
  end

  test 'group member should delete destroy own response' do
    sign_in group_member

    group_response # trigger
    assert_difference('GroupResponse.count', -1) do
      delete :destroy,
             params: {id: group_response}
    end

    assert_redirected_to motion
  end

  test "group member should not delete destroy others' response" do
    sign_in group_member

    group_response = create(:group_response,
                            group: group,
                            parent: motion.edge)
    assert_no_difference('GroupResponse.count') do
      delete :destroy,
             params: {id: group_response}
    end

    assert_not_authorized
  end

  ## Visible groups ##
  let(:visible_group_member) { create_group_member(visible_group, create_member(freetown)) }

  test 'group member should not get new on visible' do
    sign_in visible_group_member

    get :new,
        params: {
          motion_id: motion,
          group_id: visible_group,
          side: :pro
        }

    assert_response 404
  end

  test 'group member should not post create on visible' do
    sign_in visible_group_member

    assert_no_difference('GroupResponse.count') do
      post :create,
           params: {
             motion_id: motion,
             group_id: visible_group,
             group_response: attributes_for(:group_response,
                                            parent: freetown.edge)
           }
    end

    assert_response 404
  end

  ## hidden groups ##
  let(:hidden_group_member) { create_group_member(hidden_group, create_member(freetown)) }

  test 'group member should not get new on hidden' do
    sign_in hidden_group_member

    get :new,
        params: {
          motion_id: motion,
          group_id: hidden_group,
          side: :pro
        }

    assert_response 404
  end

  test 'group member should not post create on hidden' do
    sign_in hidden_group_member

    assert_no_difference('GroupResponse.count') do
      post :create,
           params: {
             motion_id: motion,
             group_id: hidden_group,
             group_response: attributes_for(:group_response,
                                            parent: freetown.edge)
           }
    end

    assert_response 404
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
             params: {id: group_response}
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
             params: {id: group_response}
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
             params: {id: group_response}
    end

    assert_redirected_to motion
  end
end
