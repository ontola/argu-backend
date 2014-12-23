require "test_helper"

class ArgumentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: arguments(:one)

    assert_response :success
    assert assigns(:argument)
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, "Trashed comments are visible"
  end

  test "should get new pro" do
    sign_in users(:user)

    get :new, motion_id: motions(:one).id, pro: 'pro'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).pro === true, "isn't assigned pro attribute"
  end

  test "should get new con" do
    sign_in users(:user)

    get :new, motion_id: motions(:one).id, pro: 'con'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).pro === false, "isn't assigned pro attribute"
  end

  test "should post create pro" do
    sign_in users(:user)

    assert_difference('Argument.count') do
      post :create, argument: {motion_id: motions(:one).id, pro: 'pro', title: 'Test argument pro', content: 'Test argument pro-tents'}
    end

    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).title == 'Test argument pro', "title isn't assigned"
    assert assigns(:argument).content == 'Test argument pro-tents', "content isn't assigned"
    assert assigns(:argument).pro === true, "isn't assigned pro attribute"
    assert_redirected_to assigns(:argument).motion
  end

  test "should post create con" do
    sign_in users(:user)

    assert_difference('Argument.count') do
      post :create, argument: {motion_id: motions(:one).id, pro: 'con', title: 'Test argument con', content: 'Test argument con-tents'}
    end

    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).title == 'Test argument con', "title isn't assigned"
    assert assigns(:argument).content == 'Test argument con-tents', "content isn't assigned"
    assert assigns(:argument).pro === false, "isn't assigned pro attribute"
    assert_redirected_to assigns(:argument).motion
  end

  test "should put update on own argument" do
    sign_in users(:user)

    put :update, id: arguments(:one), argument: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:argument)
    assert_equal 'New title', assigns(:argument).title
    assert_equal 'new contents', assigns(:argument).content
    assert_redirected_to assigns(:argument)
  end

  test "should not put update on others' argument" do
    sign_in users(:user2)

    put :update, id: arguments(:one), argument: {title: 'New title', content: 'new contents'}

    assert_equal arguments(:one), assigns(:argument)
  end
end
