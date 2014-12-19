require "test_helper"

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: questions(:one).id
    assert_response :success
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:motions)

    assert_not assigns(:motions).any?(&:is_trashed?), "Trashed motions are visible"
  end

  test "should post create" do
    sign_in users(:user)

    assert_difference('Question.count') do
      post :create, forum_id: :utrecht, question: {title: 'Question', content: 'Contents'}
    end
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_redirected_to question_url(assigns(:question))
  end

  test "should put update on own question" do
    sign_in users(:user)

    put :update, id: questions(:one), question: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
    assert_redirected_to question_url(assigns(:question))
  end

  test "should not put update on others question" do
    sign_in users(:user2)

    put :update, id: questions(:one), question: {title: 'New title', content: 'new contents'}

    assert_equal questions(:one), assigns(:question)
  end

end
