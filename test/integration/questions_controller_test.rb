# frozen_string_literal: true
require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:project) { create(:project, :with_follower, parent: freetown.edge) }
  let(:subject) do
    create(:question,
           :with_motions,
           publisher: creator,
           parent: freetown.edge)
  end
  let!(:trashed_motion) { create(:motion, is_trashed: true, parent: subject.edge) }
  let(:forum_move_to) { create_forum }

  def self.assert_no_trashed_motions
    'assigns(:motions).none? { |motion| motion.is_trashed?}'
  end

  def self.assert_motions_forum_changed
    'Motion.pluck(:forum_id).uniq == [freetown.id]'
  end

  def self.assert_not_motions_forum_changed
    'assigns(:resource).motions.pluck(:forum_id).uniq == [assigns(:resource).forum_id]'
  end

  def self.assert_has_no_motions
    'assert_equal 0, assigns(:resource).motions.count'
  end

  def self.assert_has_five_motions
    'assert_equal 5, assigns(:resource).motions.count'
  end

  define_tests do
    hash = {}
    define_test(hash, :new, suffix: ' for forum', options: {parent: :freetown})
    define_test(hash, :create, suffix: ' for project', options: {
                  analytics: stats_opt('questions', 'create_success'),
                  parent: :project
                })
    options = {
      parent: :freetown,
      analytics: stats_opt('questions', 'create_failed'),
      attributes: {title: 'Question', content: 'C'}
    }
    define_test(hash, :create, suffix: ' erroneous', options: options) do
      {member: {should: false, response: 200, asserts: [assert_has_title, assert_has_content]}}
    end
    options = {
      parent: :freetown,
      analytics: stats_opt('questions', 'create_success'),
      attributes: {
        default_cover_photo_attributes: {
          image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :create, suffix: ' with cover_photo', options: options) do
      {creator: {should: true, response: 302, asserts: [assert_photo_identifier, assert_has_photo]}}
    end
    define_test(hash, :show, asserts: [assert_no_trashed_motions])
    define_test(hash, :show, suffix: ' non-existent', options: {record: 'none'}) do
      {user: {should: false, response: 404}}
    end
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(hash, :update, suffix: ' erroneous', options: {attributes: {title: 'Question', content: 'C'}}) do
      {creator: {should: false, response: 200, asserts: [assert_has_title, assert_has_content]}}
    end
    options = {
      attributes: {
        default_cover_photo_attributes: {
          image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
        }
      }
    }
    define_test(hash, :update, suffix: ' with cover_photo', options: options) do
      {creator: {should: true, response: 302, asserts: [assert_photo_identifier, assert_has_photo]}}
    end
    define_test(hash, :destroy, options: {analytics: stats_opt('questions', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('questions', 'trash_success')})
    define_test(hash, :move)
    define_test(hash, :move!, options: {attributes: {forum_id: :forum_move_to}}) do
      user_types[:move!].merge(
        staff: {should: true, response: 302, asserts: [assert_motions_forum_changed, assert_has_no_motions]}
      )
    end
    options = {
      attributes: {
        forum_id: :forum_move_to,
        include_motions: '1'
      }
    }
    define_test(hash, :move!, suffix: ' with motions', options: options) do
      {staff: {should: true, response: 302, asserts: [assert_not_motions_forum_changed, assert_has_five_motions]}}
    end
  end
end
