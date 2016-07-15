# frozen_string_literal: true
require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  define_venice
  let(:access_token) { create(:access_token, item: venice) }
  let(:motion) { create(:motion, parent: venice.edge) }
  let(:argument) do
    create(:argument,
           parent: motion.edge,
           creator: create(:user,
                           :follows_reactions_directly)
                        .profile)
  end
  let(:comment) do
    create(:comment,
           creator: member.profile,
           parent: argument.edge)
  end

  ####################################
  # Not logged in
  ####################################

  ####################################
  # As user
  ####################################
  let(:user) { create(:user) }

  test 'should post create a comment' do
    nominatim_netherlands

    get forum_path(venice.url,
                   at: access_token.access_token)
    assert_response :success

    post forum_memberships_path(venice.url,
                                r: forum_path(venice.url),
                                at: access_token.access_token)
    assert_redirected_to new_user_session_path(r: forum_path(venice.url))
    assert_not_a_user

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
  let(:member) { create_member(venice, create(:user, :follows_reactions_directly)) }

  test 'member should not delete wipe own comment twice affecting counter caches' do
    sign_in member

    assert_equal 1, comment.commentable.comments_count

    assert_differences([['comment.commentable.reload.comments_count', -1], ['member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(comment.commentable, comment)
      delete destroy_argument_comment_path(comment.commentable, comment, destroy: 'true')
    end

    assert_redirected_to argument_path(argument, anchor: comment.id)
  end

  ####################################
  # As owner
  ####################################

  test 'owner should not delete wipe own comment twice affecting counter caches' do
    sign_in create_owner(venice)

    assert_equal 1, comment.commentable.comments_count

    assert_differences([['comment.commentable.reload.comments_count', -1], ['member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(comment.commentable, comment)
      delete destroy_argument_comment_path(comment.commentable, comment, destroy: 'true')
    end

    assert_redirected_to argument_url(argument, anchor: comment.id)
  end
end
