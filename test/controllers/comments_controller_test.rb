require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { FactoryGirl.create(:forum) }

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown, FactoryGirl.create(:user, :follows_email)) }
  let(:argument) do
    FactoryGirl.create(:argument,
                       forum: freetown,
                       creator: FactoryGirl
                                  .create(:user,
                                          :follows_email)
                                  .profile)
  end
  let(:comment) { FactoryGirl.create(:comment, profile: member.profile, commentable: argument) }

  test 'member should get show' do
    flunk 'TODO: add test before this fix for all the roles.'
  end

  test 'member should get new' do
    sign_in member

    get :new, argument_id: argument

    assert_response 200
    assert_equal argument, assigns(:commentable)
  end

  test 'member should post create comment' do
    sign_in member

    # Trip let to initialize the comment
    argument
    assert_broadcast(:create_comment_successful) do
      assert_differences create_changes_array do
        post :create,
             argument_id: argument,
             comment: {
                 body: 'Just å UTF-8 comment.'
             }
        puts
      end
    end

    assert_equal argument, assigns(:cc).resource.commentable
    assert_redirected_to argument_url(argument, anchor: assigns(:cc).resource.id)
  end

  test 'should post create comment while not logged in rendering register' do
    post :create,
         argument_id: argument,
         comment: 'Just å UTF-8 comment.'

    redirect_url = new_argument_comment_path(argument_id: argument.id,
                                             comment: {body: 'Just å UTF-8 comment.'},
                                             confirm: true)
    assert_redirected_to new_user_session_path(r: redirect_url)
    assert assigns(:resource)
  end

  test 'should put update on own comment' do
    sign_in member

    put :update,
        argument_id: comment.commentable,
        id: comment,
        comment: {body: 'new contents'}

    assert_not_nil assigns(:comment)
    assert_equal 'new contents', assigns(:comment).body
    assert_redirected_to comment_url(assigns(:comment))
  end

  test 'should put update invalid data on own comment' do
    sign_in member

    put :update,
        argument_id: comment.commentable,
        id: comment,
        comment: {body: ''}

    assert_not_nil assigns(:comment)
    assert_response 200
  end

  test 'member should not put update on other comment' do
    sign_in create_member(freetown)

    put :update,
        argument_id: comment.commentable,
        id: comment,
        comment: {
          body: 'new contents'
        }

    assert_not_nil assigns(:comment)
    assert_equal 'comment', assigns(:comment).body
    assert_redirected_to root_url
  end

  test 'member should delete destroy own comment' do
    sign_in member

    # Trip let to initialize the comment
    comment
    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy,
             argument_id: comment.commentable.id,
             id: comment
    end

    assert_redirected_to argument_path(argument, anchor: comment.id)
  end

  test 'member should not delete destroy own comment twice affecting counter caches' do
    sign_in member

    assert_equal 1, comment.commentable.comments_count

    assert_difference('comment.commentable.reload.comments_count', -1) do
      delete :destroy, argument_id: comment.commentable.id, id: comment
      delete :destroy, argument_id: comment.commentable.id, id: comment
    end

    assert_redirected_to argument_path(argument, anchor: comment.id)
  end

  test "member should not delete destroy on others' comment" do
    sign_in create_member(freetown)

    # Trip let to initialize the comment
    comment
    # The no-difference currently says nothing since comments are preserved due to nesting issues,
    # but does become relevant in the future when tree trimming is enabled.
    assert_no_difference('Comment.count') do
      delete :destroy,
             argument_id: comment.commentable.id,
             id: comment
    end

    assert_redirected_to root_path
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should not delete wipe own comment twice affecting counter caches' do
    sign_in freetown.page.owner.profileable

    assert_equal 1, comment.commentable.comments_count

    redirect_path = argument_url(argument, anchor: comment.id)
    assert_difference('comment.commentable.reload.comments_count', -1) do
      delete :destroy,
             argument_id: comment.commentable.id,
             id: comment,
             wipe: 'true'
      assert_redirected_to redirect_path
      delete :destroy,
             argument_id: comment.commentable.id,
             id: comment,
             wipe: 'true'
      assert_redirected_to redirect_path
    end
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  test 'staff should destroy comments' do
    comment = FactoryGirl.create(:comment,
                                 commentable: FactoryGirl.create(:argument,
                                                                 forum: freetown),
                                 profile: member.profile)
    FactoryGirl.create_list(:notification, 10,
                            activity: Activity.find_by(trackable: comment))
    sign_in staff

    delete :destroy,
           argument_id: comment.commentable.id,
           id: comment,
           wipe: 'true'

    assert_redirected_to argument_url(comment.commentable, anchor: comment.id)
  end

  private
  def create_changes_array
    [['Comment.count', 1],
     ['Activity.count', 1],
     ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', 1],
     ['Notification.count', 1]]
  end
end
