require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { create(:forum) }
  let(:argument) do
    create(:argument,
           forum: freetown,
           creator: create(:user,
                           :follows_email)
                      .profile)
  end
  let(:comment) do
    create(:comment,
           creator: member.profile,
           commentable: argument)
  end

  let(:cairo) { create(:forum, :closed) }
  let(:closed_argument) { create(:argument, forum: cairo) }
  let(:cairo_comment) do
    create(:comment,
           creator: member.profile,
           commentable: closed_argument)
  end

  let(:second_cairo) { create(:forum, :closed) }
  let(:second_closed_argument) { create(:argument, forum: second_cairo) }
  let(:second_cairo_comment) do
    create(:comment,
           creator: member.profile,
           commentable: second_closed_argument)
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get show' do
    get :show, id: comment

    assert_redirected_to argument_path(argument, anchor: comment.identifier)
  end

  test 'guest should not get show on cairo' do
    get :show, id: cairo_comment

    assert_redirected_to root_path
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown, create(:user, :follows_email)) }
  let(:cairo_member) { create_member(cairo, create(:user, :follows_email)) }

  test 'member should get show' do
    sign_in member

    get :show, id: comment

    assert_redirected_to argument_path(argument, anchor: comment.identifier)
  end

  test 'guest should get show on cairo' do
    sign_in cairo_member

    get :show, id: cairo_comment

    assert_redirected_to argument_path(closed_argument, anchor: cairo_comment.identifier)
  end

  test 'guest should not get show on second_cairo' do
    sign_in cairo_member

    get :show, id: second_cairo_comment

    assert_redirected_to root_path
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

    assert_equal argument, assigns(:create_service).resource.commentable
    assert_redirected_to argument_url(argument, anchor: assigns(:create_service).resource.identifier)
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

    assert_not_nil assigns(:update_service).resource
    assert_equal 'new contents', assigns(:update_service).resource.body
    assert_redirected_to comment_url(assigns(:update_service).resource)
  end

  test 'should put update invalid data on own comment' do
    sign_in member

    put :update,
        argument_id: comment.commentable,
        id: comment,
        comment: {body: ''}

    assert_not_nil assigns(:update_service).resource
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

    assert_not_authorized
    assert_redirected_to comment.forum
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

    assert_not_authorized
    assert_redirected_to comment.forum
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should get show' do
    sign_in freetown.page.owner.profileable

    get :show, id: comment

    assert_redirected_to argument_path(argument, anchor: comment.identifier)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should destroy comments' do
    comment = create(:comment,
                     commentable: create(:argument,
                                         forum: freetown),
                     creator: member.profile)
    create_list(:notification,
                10,
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
