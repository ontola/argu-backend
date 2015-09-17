require 'test_helper'

class CommentsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }

  ####################################
  # As guest
  ####################################
  test 'should post create comment while not logged in rendering register', tenant: :holland do
    post :create,
         argument_id: argument,
         comment: 'Just å UTF-8 comment.'

    assert_response 200
    assert assigns(:resource)
  end

  ####################################
  # As member
  ####################################
  let(:holland_member) { make_member(holland) }
  let!(:argument) { FactoryGirl.create(:argument, :with_comments, tenant: :holland) }
  let!(:comment) { FactoryGirl.create(:comment, creator: creator.profile, commentable: argument) }

  test 'should post create comment', tenant: :holland do
    sign_in holland_member

    assert_difference('Comment.count') do
      post :create,
           argument_id: argument,
           comment: {
               body: 'Just å UTF-8 comment.'
           }
    end

    assert assigns(:comment)
    assert_equal argument, assigns(:comment).commentable
    assert_redirected_to argument_url(argument, anchor: assigns(:comment).id)
  end

  test 'should not put update on other comment', tenant: :holland do
    sign_in holland_member

    put :update, id: comment, comment: {body: 'new contents'}

    assert_not_nil assigns(:comment)
    assert_equal 'comment', assigns(:comment).body
    assert_redirected_to root_url
  end

  test "'should not delete destroy on others' comment'" do
    sign_in holland_member

    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy, id: comment
    end

    assert_redirected_to root_path
  end

  ####################################
  # As creator
  ####################################
  let(:creator) { make_member(holland) }

  test 'should put update on own comment', tenant: :holland do
    sign_in creator

    put :update, id: comment, comment: {body: 'new contents'}

    assert_redirected_to comment_url(assigns(:comment))
    assert_not_nil assigns(:comment)
    assert_equal 'new contents', assigns(:comment).body
  end

  test 'should delete destroy own comment', tenant: :holland do
    sign_in creator

    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy, id: comment
    end

    assert_redirected_to argument_path(argument, anchor: comment.id)
  end

  test 'should not delete destroy own comment twice affecting counter caches', tenant: :holland do
    sign_in creator

    assert_equal comment.commentable_comments_count,
                 comment.commentable.comments_count
    assert comment.commentable.comment_threads.count > 1

    assert_difference('comment.commentable.reload.comments_count', -1) do
      delete :destroy, id: comment
      assert_redirected_to argument_path(argument, anchor: comment.id)
      delete :destroy, id: comment
      assert_response 404
    end

  end

  ####################################
  # As owner
  ####################################
  let(:owner) { make_owner(holland) }

  test 'should not delete wipe own comment twice affecting counter caches', tenant: :holland do
    sign_in owner

    assert_equal comment.commentable_comments_count,
                 comment.commentable.comments_count
    assert comment.commentable.comment_threads.count > 1

    assert_difference('comment.commentable.reload.comments_count', -1) do
      delete :destroy, id: comment, wipe: 'true'
      assert_redirected_to argument_url(argument, anchor: comment.id)
      delete :destroy, id: comment, wipe: 'true'
      assert_response 404
    end
  end

  ####################################
  # As staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  test 'should destroy comments', tenant: :holland do
    FactoryGirl.create_list(:notification, 40, activity: Activity.find_by(trackable: comment))
    sign_in staff

    delete :destroy, argument_id: comment.commentable.id, id: comment, wipe: 'true'

    assert_redirected_to argument_url(comment.commentable, anchor: comment.id)
  end
end
