# frozen_string_literal: true
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
        guest: exp_res(asserts: [assert_not_a_user], analytics: false),
        user: exp_res(asserts: [assert_not_authorized], analytics: false),
        member: exp_res(asserts: [assert_not_authorized], analytics: false),
        moderator: exp_res(asserts: [assert_not_authorized], analytics: false),
        manager: exp_res(asserts: [assert_not_authorized], analytics: false),
        owner: exp_res(asserts: [assert_not_authorized], analytics: false),
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    options = {
      analytics: stats_opt('motions', 'create_success'),
      actor: :page,
      parent: :freetown
    }
    define_test(hash, :create, suffix: ' as page', options: options) do
      {owner: exp_res(should: true, asserts: [assert_as_page])}
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' for forum', options: options)
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
    options = {
      analytics: stats_opt('motions', 'create_success'),
      parent: :closed_question
    }
    define_test(hash, :create, suffix: ' for closed question', options: options) do
      {
        guest: exp_res(asserts: [assert_not_a_user], analytics: false),
        user: exp_res(asserts: [assert_not_authorized], analytics: false),
        member: exp_res(asserts: [assert_not_authorized], analytics: false),
        moderator: exp_res(asserts: [assert_not_authorized], analytics: false),
        manager: exp_res(asserts: [assert_not_authorized], analytics: false),
        owner: exp_res(asserts: [assert_not_authorized], analytics: false),
        staff: exp_res(asserts: [assert_not_authorized], analytics: false)
      }
    end
    options = {
      parent: :require_question_question,
      analytics: stats_opt('motions', 'create_success')
    }
    define_test(hash, :create, suffix: ' with required question', options: options) do
      {require_question_member: exp_res(should: true)}
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
          image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :create, suffix: ' with cover_photo', options: options) do
      {creator: exp_res(should: true, asserts: [assert_photo_identifier, assert_has_photo])}
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
      {creator: exp_res(should: true, asserts: [assert_is_trashed])}
    end
    options = {
      attributes: {
        default_cover_photo_attributes: {
          image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :update, suffix: ' with cover_photo', options: options) do
      {creator: exp_res(should: true, asserts: [assert_photo_identifier, assert_has_photo])}
    end
    define_test(hash, :trash, options: {analytics: stats_opt('motions', 'trash_success')})
    define_test(hash, :destroy, options: {analytics: stats_opt('motions', 'destroy_success')})
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
end
