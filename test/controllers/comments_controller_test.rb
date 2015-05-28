require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # As user
  ####################################
  test 'should post create comment' do
    sign_in users(:user)

    assert_difference('Comment.count') do
      post :create,
           argument_id: arguments(:one),
           comment: {
               body: 'Just å UTF-8 comment.'
           }
    end

    assert assigns(:comment)
    assert_equal arguments(:one), assigns(:comment).commentable
    assert_redirected_to argument_url(arguments(:one), anchor: assigns(:comment).id)
  end

  test 'should post create comment while not logged in rendering register' do
    post :create,
         argument_id: arguments(:one),
         comment: 'Just å UTF-8 comment.'

    assert_response 200
    assert assigns(:resource)
  end

  test 'should delete destroy own comment' do
    sign_in users(:user)

    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy, argument_id: comments(:one).commentable.id, id: comments(:one)
    end

    assert_redirected_to argument_path(arguments(:one), anchor: comments(:one).id)
  end

  test "'should not delete destroy on others' comment'" do
    sign_in users(:user2)

    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy, argument_id: comments(:one).commentable.id, id: comments(:one)
    end

    assert_redirected_to root_path
  end
end
