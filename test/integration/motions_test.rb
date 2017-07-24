# frozen_string_literal: true
require 'test_helper'

class MotionsTest < ActionDispatch::IntegrationTest
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
           edge_attributes: {expires_at: 1.day.ago},
           parent: freetown.edge,
           creator: create(:profile_direct_email))
  end
  let(:trashed_question) do
    create(:question,
           :with_follower,
           edge_attributes: {trashed_at: 1.day.ago},
           parent: freetown.edge,
           creator: create(:profile_direct_email))
  end
  let(:project) { create(:project, :with_follower, parent: freetown.edge) }
  let(:subject) do
    create(:motion,
           :with_arguments,
           :with_votes,
           publisher: creator,
           parent: question.edge)
  end
  let(:member_motion) { create(:motion, parent: freetown.edge, creator: member.profile) }

  let(:forum_move_to) { create_forum }
  let(:require_question_forum) do
    forum = create_forum
    create(:rule,
           branch: forum.edge,
           model_type: 'Motion',
           action: 'create_without_question?',
           role: 'member',
           permit: false,
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

  def self.assert_as_page
    "Motion.last.creator.profileable_type == 'Page'"
  end

  def self.assert_no_trashed_arguments
    'assigns(:arguments).none? { |arr| arr[1][:collection].any?(&:is_trashed?) }'
  end

  def self.assert_is_trashed
    'resource.reload.is_trashed?'
  end

  define_tests do
    hash = {}
    define_test(hash, :new, suffix: ' for forum', options: {parent: :freetown})
    define_test(hash, :new, suffix: ' for question', options: {parent: :question})
    define_test(hash, :new, suffix: ' for project', options: {parent: :project})
    define_test(hash, :new, suffix: ' for closed question', options: {parent: :closed_question}) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
        user: exp_res(asserts: [assert_not_authorized], analytics: false),
        member: exp_res(asserts: [assert_not_authorized], analytics: false),
        manager: exp_res(asserts: [assert_not_authorized], analytics: false),
        super_admin: exp_res(asserts: [assert_not_authorized], analytics: false),
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    define_test(hash, :new, suffix: ' for trashed question', options: {parent: :trashed_question}) do
      {
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    options = {
      analytics: stats_opt('motions', 'create_success'),
      actor: :page,
      parent: :freetown
    }
    define_test(hash, :create, suffix: ' as page', options: options) do
      {super_admin: exp_res(response: 302, should: true, asserts: [assert_as_page])}
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' for forum', options: options)
    options = {
      parent: :freetown,
      attributes: {
        edge_attributes: {argu_publication_attributes: {publish_type: :schedule}}
      }
    }
    define_test(hash, :create, suffix: ' scheduled', options: options) do
      {user: exp_res(should: false)}
    end
    options = {
      parent: :question,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' for question', options: options)
    options = {
      parent: :project,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' for project', options: options)
    define_test(hash, :create, suffix: ' for closed question', options: {parent: :closed_question}) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
        user: exp_res(asserts: [assert_not_authorized], analytics: false),
        member: exp_res(asserts: [assert_not_authorized], analytics: false),
        manager: exp_res(asserts: [assert_not_authorized], analytics: false),
        super_admin: exp_res(asserts: [assert_not_authorized], analytics: false),
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    define_test(hash, :create, suffix: ' for trashed question', options: {parent: :trashed_question}) do
      {
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    options = {
      parent: :require_question_question,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' with required question', options: options) do
      {require_question_member: exp_res(should: true, response: 302)}
    end
    define_test(hash, :create, suffix: ' without required question', options: {parent: :require_question_forum}) do
      {require_question_member: exp_res(asserts: [])}
    end
    options = {
      parent: :project,
      attributes: {title: 'Motion', content: 'C'},
      analytics: stats_opt('motions', 'create_failed')
    }
    define_test(hash, :create, suffix: ' erroneous', options: options) do
      {member: exp_res(response: 200, asserts: [assert_has_title, assert_has_content])}
    end
    options = {
      parent: :project,
      analytics: stats_opt('motions', 'create_success'),
      attributes: {
        default_cover_photo_attributes: {
          content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :create, suffix: ' with cover_photo', options: options) do
      {creator: exp_res(response: 302, should: true, asserts: [assert_photo_identifier, assert_has_media_object])}
    end
    options = {
      parent: :project,
      analytics: stats_opt('motions', 'create_success'),
      attributes: {
        attachments_attributes: {
          '1234': {
            content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      }
    }
    define_test(hash, :create, suffix: ' with attachment', options: options) do
      {creator: exp_res(response: 302, should: true, asserts: [assert_attachment_identifier, assert_has_media_object])}
    end
    define_test(hash, :show, asserts: [assert_no_trashed_arguments]) do
      user_types[:show].except!(:non_member)
    end
    define_test(hash, :show, suffix: ' non-existent', options: {record: 'none'}) do
      {user: exp_res(response: 404)}
    end
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(hash, :update, suffix: ' erroneous', options: {attributes: {title: 'Motion', content: 'C'}}) do
      {creator: exp_res(response: 200, asserts: [assert_has_title, assert_has_content])}
    end
    options = {
      attributes: {
        edge_attributes: {
          is_trashed: '1'
        }
      }
    }
    define_test(hash, :update, suffix: ' trash', options: options) do
      {creator: exp_res(response: 302, should: true, asserts: [assert_is_trashed])}
    end
    options = {
      attributes: {
        default_cover_photo_attributes: {
          content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :update, suffix: ' with cover_photo', options: options) do
      {creator: exp_res(response: 302, should: true, asserts: [assert_photo_identifier, assert_has_media_object])}
    end
    options = {
      attributes: {
        attachments_attributes: {
          '1234': {
            content: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      }
    }
    define_test(hash, :update, suffix: ' with attachment', options: options) do
      {creator: exp_res(response: 302, should: true, asserts: [assert_attachment_identifier, assert_has_media_object])}
    end
    define_test(hash, :trash, options: {analytics: stats_opt('motions', 'trash_success')})
    define_test(
      hash,
      :destroy,
      options: {
        analytics: stats_opt('motions', 'destroy_success'),
        differences: [['Motion', -1], ['Vote', -9], ['Argu::Redis.keys(\'temporary.*\')', -6], ['Activity.loggings', 1]]
      }
    )
    define_test(hash, :shift)
    define_test(hash, :move, options: {attributes: {forum_id: :forum_move_to}})
  end

  test 'member should show tutorial only on first post create' do
    sign_in member

    general_create(
      analytics: stats_opt('motions', 'create_success'),
      parent: :freetown,
      results: {
        should: :true,
        response: 302
      }
    )
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
      }
    )
    assert_not_nil assigns(:create_service).resource

    assert_redirected_to motion_path(assigns(:create_service).resource)
  end

  test 'creator should decouple a motion from a question' do
    sign_in creator

    general_update(
      attributes: {question_id: ''},
      results: {
        should: :true,
        response: 302
      }
    )
    subject.reload
    assert_nil subject.question_id
    assert_equal subject.parent_model, freetown
  end
end
