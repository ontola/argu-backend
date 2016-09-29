require 'test_helper'

class MotionsControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:question) do
    create(:question,
           :with_follower,
           parent: freetown.edge,
           options: {
            creator: create(:profile_direct_email)
           })
  end
  let(:closed_question) do
    create(:question,
           :with_follower,
           expires_at: 1.day.ago,
           parent: freetown.edge,
           creator: create(:profile_direct_email))
  end
  let(:project) { create(:project, :with_follower, parent: freetown.edge) }
  let(:subject) do
    create(:motion,
           :with_arguments,
           publisher: creator,
           parent: question.edge)
  end
  let(:member_motion) { create(:motion, parent: freetown.edge, creator: member.profile) }

  let(:forum_move_to) { create_forum }
  let(:require_question_forum) do
    forum = create_forum
    create(:rule,
           model_type: 'Motion',
           action: 'create_without_question?',
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: forum.id,
           trickles: Rule.trickles[:trickles_down])
    forum
  end
  let(:require_question_question) do
    user = create(:user, :follows_reactions_directly)
    create(:question,
           parent: require_question_forum.edge,
           creator: user.profile)
  end

  let(:require_question_member) { create_member(require_question_forum) }

  define_tests do
    hash = {}
    define_test(hash, :new, case_suffix: ' for forum', options: {parent: :freetown})
    define_test(hash, :new, case_suffix: ' for question', options: {parent: :question})
    define_test(hash, :new, case_suffix: ' for project', options: {parent: :project})
    define_test(
      hash,
      :new,
      case_suffix: ' for closed question',
      options: {parent: :closed_question},
      user_types: {
        guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)'],
                analytics: false},
        user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)'],
               analytics: false},
        member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                 analytics: false},
        moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                    analytics: false},
        manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                  analytics: false},
        owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                analytics: false},
        staff: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                analytics: false}
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' as page',
      options: {
        analytics: stats_opt('motions', 'create_success'),
        actor: :page,
        parent: :freetown
      },
      user_types: {
        owner: {
          should: true,
          response: 302,
          asserts: ["Motion.last.creator.profileable_type == 'Page'"]
        }
      }
    )
    define_test(hash, :create, case_suffix: ' for forum', options: {
      parent: :freetown,
      analytics: stats_opt('motions', 'create_success')
    })
    define_test(hash, :create, case_suffix: ' for question', options: {
      parent: :question,
      analytics: stats_opt('motions', 'create_success')
    })
    define_test(hash, :create, case_suffix: ' for project', options: {
      parent: :project,
      analytics: stats_opt('motions', 'create_success')
    })
    define_test(
      hash,
      :create,
      case_suffix: ' for closed question',
      options: {
        analytics: stats_opt('motions', 'create_success'),
        parent: :closed_question
      },
      user_types: {
        guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)'],
                analytics: false},
        user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)'],
               analytics: false},
        member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                 analytics: false},
        moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                    analytics: false},
        manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                  analytics: false},
        owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                analytics: false},
        staff: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                analytics: false}
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' with required question',
      options: {
        parent: :require_question_question,
        analytics: stats_opt('motions', 'create_success')
      },
      user_types: {require_question_member: {should: true, response: 302}})
    define_test(
      hash,
      :create,
      case_suffix: ' without required question',
      options: {parent: :require_question_forum},
      user_types: {require_question_member: {should: false, response: 302}})
    define_test(
      hash,
      :create,
      case_suffix: ' erroneous',
      options: {
        parent: :project,
        attributes: {title: 'Motion', content: 'C'},
        analytics: stats_opt('motions', 'create_failed')
      },
      user_types: {
        member: {
          should: false,
          response: 200,
          asserts: ['assert_select "#motion_title", "Motion"',
                    'assert_select "#motion_content", "C"']}
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' with cover_photo',
      options: {
        parent: :project,
        analytics: stats_opt('motions', 'create_success'),
        attributes: {
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      },
      user_types: {
        creator: {
          should: true,
          response: 302,
          asserts: [
            'assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
            'assert_equal 1, resource.photos.count']}
      }
    )
    define_test(hash, :show, asserts: [
      'assigns(:motion)',
      'assigns(:vote)',
      'subject.arguments.where(is_trashed: true).count > 0',
      '!(assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) })'
    ])
    define_test(hash, :show, case_suffix: ' non-existent', options: {record: 'none'}, user_types: {
      user: {should: false, response: 404}
    })
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(
      hash,
      :update,
      case_suffix: ' erroneous',
      options: {attributes: {title: 'Motion', content: 'C'}},
      user_types: {
        creator: {
          should: false, response: 200, asserts: [
            'assert_select "#motion_title", "Motion"',
            'assert_select "#motion_content", "C"']
        }
      }
    )
    define_test(
      hash,
      :update,
      case_suffix: ' with cover_photo',
      options: {
        attributes: {
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      },
      user_types: {
        creator: {
          should: true,
          response: 302,
          asserts: [
            'assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
            'assert_equal 1, resource.photos.count']}
      }
    )
    define_test(hash, :trash, options: {
      analytics: stats_opt('motions', 'trash_success')
    })
    define_test(hash,
                :destroy,
                options: {analytics: stats_opt('motions', 'destroy_success')})
    define_test(hash, :move)
    define_test(hash, :move!, options: {attributes: {forum_id: :forum_move_to}})
  end

  test 'member should show tutorial only on first post create' do
    sign_in member

    general_create(
      analytics: stats_opt('motions', 'create_success'),
      parent: :freetown,
      results: {
        should: :true,
        response: 302
      })
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource, start_motion_tour: true)
    WebMock.reset!
    analytics_collect

    general_create(
      analytics: stats_opt('motions', 'create_success'),
      parent: :freetown,
      results: {
        should: :true,
        response: 302
      })
    assert_not_nil assigns(:create_service).resource

    assert_redirected_to motion_path(assigns(:create_service).resource)
  end
end
