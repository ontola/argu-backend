# frozen_string_literal: true
require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:cairo_member) { create_member(cairo) }
  let(:venice_member) { create_member(venice) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) do
    create(:argument,
           :with_follower,
           parent: motion.edge,
           creator: create(:profile_direct_email))
  end
  let(:subject) do
    create(:comment,
           publisher: creator,
           parent: argument.edge)
  end

  define_cairo
  let(:cairo_motion) { create(:motion, parent: cairo.edge) }
  let(:cairo_argument) { create(:argument, parent: cairo_motion.edge) }
  let(:cairo_subject) do
    create(:comment,
           creator: member.profile,
           parent: cairo_argument.edge)
  end

  define_cairo('second_cairo')
  let(:second_cairo_motion) { create(:motion, parent: second_cairo.edge) }
  let(:second_cairo_argument) { create(:argument, parent: second_cairo_motion.edge) }
  let(:second_cairo_subject) do
    create(:comment,
           creator: member.profile,
           parent: second_cairo_argument.edge)
  end

  def edit_path(record)
    url_for([:edit, record.commentable, record])
  end

  def update_path(record)
    url_for([record.commentable, record])
  end

  def destroy_path(record)
    url_for([record.commentable, record, destroy: true])
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :argument})
    define_test(
      hash,
      :create,
      options: {
        parent: :argument,
        analytics: stats_opt('comments', 'create_success'),
        attributes: {body: 'Just å UTF-8 comment.'}
      },
      user_types: user_types[:create].merge(
        guest: {
          should: false,
          response: 302,
          analytics: false,
          asserts: [
            'assigns(:_not_a_user_caught)',
            'assert_redirected_to new_user_session_path(r: new_argument_comment_path(argument_id: '\
            "argument.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
          ]
        }
      )
    )
    # @todo body is lost on errorneous post
    define_test(
      hash,
      :create,
      case_suffix: ' erroneous',
      options: {
        parent: :argument,
        analytics: stats_opt('comments', 'create_failed'),
        attributes: {body: 'C'}
      },
      user_types: {
        manager: {
          should: false,
          response: 302
        }
      }
    )
    define_test(
      hash,
      :show,
      asserts: ['assert_redirected_to argument_path(argument, anchor: subject.identifier)'],
      user_types: {
        guest: {should: true, response: 302},
        user: {should: true, response: 302},
        member: {should: true, response: 302},
        moderator: {should: true, response: 302},
        manager: {should: true, response: 302},
        owner: {should: true, response: 302},
        staff: {should: true, response: 302}
      }
    )
    define_test(
      hash,
      :show,
      case_suffix: ' cairo',
      options: {record: :cairo_subject},
      user_types: {
        guest: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        user: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        member: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        moderator: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        manager: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        owner: {should: false, response: 302, asserts: ['assert_redirected_to root_path']},
        cairo_member: {should: true, response: 302, asserts: [
          'assert_redirected_to argument_path(cairo_argument, anchor: cairo_subject.identifier)'
        ]},
        staff: {should: true, response: 302, asserts: [
          'assert_redirected_to argument_path(cairo_argument, anchor: cairo_subject.identifier)'
        ]}
      }
    )
    define_test(
      hash,
      :show,
      case_suffix: ' cairo',
      options: {record: :second_cairo_subject},
      user_types: {
        cairo_member: {should: false, response: 302, asserts: ['assert_redirected_to root_path']}
      }
    )
    define_test(hash, :show, case_suffix: ' non-existent', options: {record: 'none'}, user_types: {
                  user: {should: false, response: 404}
                })
    define_test(hash, :edit, user_types: {
                  guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)']},
                  user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)']},
                  member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  creator: {should: true, response: 200},
                  moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  staff: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
                })
    define_test(hash, :update, user_types: {
                  guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)']},
                  user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)']},
                  member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  creator: {should: true, response: 302},
                  moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
                  staff: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
                })
    define_test(
      hash,
      :update,
      case_suffix: ' erroneous',
      options: {attributes: {body: 'C'}},
      user_types: {
        creator: {
          should: false,
          response: 200,
          asserts: ['assert_select "#comment_body", "C"']
        }
      }
    )
    define_test(hash, :destroy, options: {
                  differences: [['Comment.where(body: "")', 1], ['Activity.loggings', 1]],
                  analytics: stats_opt('comments', 'destroy_success')
                })
    define_test(hash, :trash, options: {analytics: stats_opt('comments', 'trash_success')})
  end

  # ####################################
  # # As user
  # ####################################
  define_venice
  let(:access_token) { create(:access_token, item: venice) }
  let(:venice_motion) { create(:motion, parent: venice.edge) }
  let(:venice_argument) do
    create(:argument,
           parent: venice_motion.edge,
           creator: create(:user,
                           :follows_reactions_directly)
                      .profile)
  end
  let(:venice_comment) do
    create(:comment,
           creator: venice_member.profile,
           parent: venice_argument.edge)
  end

  test 'spectator should post create a comment' do
    nominatim_netherlands

    get forum_path(venice.url, params: {at: access_token.access_token})
    assert_response :success

    post group_membership_index_path(venice.members_group.id,
                                     r: forum_path(venice.url),
                                     at: access_token.access_token)
    assert_redirected_to new_user_session_path(r: forum_path(venice.url))
    assert_not_a_user

    follow_redirect!

    assert_differences [['User.count', 1],
                        ['Sidekiq::Worker.jobs.size', 1]] do
      post user_registration_path,
           params: {
             user: {
               shortname_attributes: {shortname: 'newuser'},
               email: 'newuser@example.com',
               password: 'useruser',
               password_confirmation: 'useruser',
               r: venice.url
             },
             at: access_token.access_token
           }
      assert_redirected_to edit_user_url('newuser')
    end
    follow_redirect!

    put setup_profiles_path,
        params: {
          user: {
            first_name: 'new',
            last_name: 'user',
            profile_attributes: {
              id: Profile.last.id,
              about: 'Something ab'
            }
          }
        }
    assert_redirected_to forum_url(venice.url)
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).grants.member.count
  end

  ####################################
  # As member
  ####################################
  test 'member should not delete wipe own comment twice affecting counter caches' do
    sign_in venice_member

    assert_equal 1, venice_comment.commentable.comments_count

    assert_differences([['venice_comment.commentable.reload.comments_count', -1],
                        ['venice_member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(venice_comment.commentable, venice_comment)
      delete destroy_argument_comment_path(
        venice_comment.commentable,
        venice_comment,
        destroy: 'true'
      )
    end

    assert_redirected_to argument_path(venice_argument, anchor: venice_comment.id)
  end

  ####################################
  # As owner
  ####################################
  test 'owner should not delete wipe own comment twice affecting counter caches' do
    sign_in create_owner(venice)

    assert_equal 1, venice_comment.commentable.comments_count

    assert_differences([['venice_comment.commentable.reload.comments_count', -1],
                        ['venice_member.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(venice_comment.commentable, venice_comment)
      delete destroy_argument_comment_path(
        venice_comment.commentable,
        venice_comment,
        destroy: 'true'
      )
    end

    assert_redirected_to argument_url(venice_argument, anchor: venice_comment.id)
  end
end
