require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }

  ####################################
  # As user
  ####################################
  let(:user) { create_member(holland) }
  let(:argument) { FactoryGirl.create(:argument, forum: holland) }
  let(:comment) { FactoryGirl.create(:comment, profile: user.profile, commentable: argument) }

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

  test 'should put update on own comment' do
    sign_in user

    put :update, argument_id: comment.commentable, id: comment, comment: {body: 'new contents'}

    assert_not_nil assigns(:comment)
    assert_equal 'new contents', assigns(:comment).body
    assert_redirected_to comment_url(assigns(:comment))
  end

  test 'should put update invalid data on own comment' do
    sign_in user

    put :update, argument_id: comment.commentable, id: comment, comment: {body: ''}

    assert_not_nil assigns(:comment)
    assert_response 200
  end

  test 'should not put update on other comment' do
    sign_in create_member(holland)

    put :update, argument_id: comment.commentable, id: comment, comment: {body: 'new contents'}

    assert_not_nil assigns(:comment)
    assert_equal 'comment', assigns(:comment).body
    assert_redirected_to root_url
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

  test 'should not delete destroy own comment twice affecting counter caches' do
    sign_in users(:user)

    assert_equal 1, comments(:one).commentable.comments_count

    assert_difference('comments(:one).commentable.reload.comments_count', -1) do
      delete :destroy, argument_id: comments(:one).commentable.id, id: comments(:one)
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

  ####################################
  # As owner
  ####################################
  test 'should not delete wipe own comment twice affecting counter caches' do
    sign_in users(:user_thom)

    assert_equal 1, comments(:one).commentable.comments_count

    assert_difference('comments(:one).commentable.reload.comments_count', -1) do
      delete :destroy, argument_id: comments(:one).commentable.id, id: comments(:one), wipe: 'true'
      delete :destroy, argument_id: comments(:one).commentable.id, id: comments(:one), wipe: 'true'
    end

    assert_redirected_to argument_url(arguments(:one), anchor: comments(:one).id)
  end

  ####################################
  # As staff
  ####################################
  test 'should destroy comments' do
    comment = FactoryGirl.create(:comment,
                       commentable: FactoryGirl.create(:argument),
                       profile: user.profile)
    FactoryGirl.create_list(:notification, 40, activity: Activity.find_by(trackable: comment))
    sign_in users(:user_thom)

    delete :destroy, argument_id: comment.commentable.id, id: comment, wipe: 'true'

    assert_redirected_to argument_url(comment.commentable, anchor: comment.id)
  end
end
