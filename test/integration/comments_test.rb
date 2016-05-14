require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  define_common_objects :user
  let!(:venice) { create(:forum, :vwal) }
  let(:access_token) { create(:access_token, item: venice) }
  let(:argument) do
    create(:argument,
           forum: venice,
           creator: create(:user,
                           :follows_email)
                        .profile)
  end
  let(:comment) do
    create(:comment,
           creator: member.profile,
           commentable: argument)
  end

  ####################################
  # Not logged in
  ####################################

  ####################################
  # As User
  ####################################
  test 'should post create a comment' do
    nominatim_netherlands

    get forum_path(venice.url,
                   at: access_token.access_token)
    assert_response :success

    post forum_memberships_path(venice.url,
                                r: forum_path(venice.url),
                                at: access_token.access_token)
    assert_redirected_to new_user_session_path(r: forum_path(venice.url))
    assert assigns(:resource)

    follow_redirect!

    assert_differences [['User.count', 1],
                        ['Sidekiq::Worker.jobs.size', 1]] do
      post user_registration_path,
           user: {
             shortname_attributes: {shortname: 'newuser'},
             email: 'newuser@example.com',
             password: 'useruser',
             password_confirmation: 'useruser',
             r: venice.url
           },
           at: access_token.access_token
    end
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!

    put profile_path('newuser'),
        profile: {
          profileable_attributes: {
            first_name: 'new',
            last_name: 'user'
          },
          about: 'Something ab'
        }
    assert_redirected_to forum_url(venice.url)
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count
  end

  ####################################
  # As member
  ####################################
  let(:member) { create_member(venice, create(:user, :follows_email)) }

  test 'member should not delete wipe own comment twice affecting counter caches' do
    log_in_user member

    assert_equal 1, comment.commentable.comments_count

    assert_differences([['comment.commentable.reload.comments_count', -1],['member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(comment.commentable, comment)
      delete destroy_argument_comment_path(comment.commentable, comment, destroy: 'true')
    end

    assert_redirected_to argument_path(argument, anchor: comment.id)
  end

  ####################################
  # As owner
  ####################################
  test 'owner should not delete wipe own comment twice affecting counter caches' do
    log_in_user venice.page.owner.profileable

    assert_equal 1, comment.commentable.comments_count

    assert_differences([['comment.commentable.reload.comments_count', -1],['member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(comment.commentable, comment)
      delete destroy_argument_comment_path(comment.commentable, comment, destroy: 'true')
    end

    assert_redirected_to argument_url(argument, anchor: comment.id)
  end
end
