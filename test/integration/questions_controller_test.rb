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
    define_test(hash, :new, case_suffix: ' for forum', options: {parent: :freetown})
    define_test(hash, :create, case_suffix: ' for project', options: {
                  analytics: stats_opt('questions', 'create_success'),
                  parent: :project
                })
    define_test(
      hash,
      :create,
      case_suffix: ' erroneous',
      options: {
        parent: :freetown,
        analytics: stats_opt('questions', 'create_failed'),
        attributes: {title: 'Question', content: 'C'}
      },
      user_types: {
        member: {should: false, response: 200, asserts: [assert_has_title, assert_has_content]}
      }
    )
    define_test(
      hash,
      :create,
      case_suffix: ' with cover_photo',
      options: {
        parent: :freetown,
        analytics: stats_opt('questions', 'create_success'),
        attributes: {
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }
      },
      user_types: {
        creator: {should: true, response: 302, asserts: [assert_photo_identifier, assert_has_photo]}
      }
    )
    define_test(hash, :show, asserts: [assert_no_trashed_motions])
    define_test(hash, :show, case_suffix: ' non-existent', options: {record: 'none'}, user_types: {
                  user: {should: false, response: 404}
                })
    define_test(hash, :edit)
    define_test(hash, :update)
    define_test(
      hash,
      :update,
      case_suffix: ' erroneous',
      options: {attributes: {title: 'Question', content: 'C'}},
      user_types: {
        creator: {should: false, response: 200, asserts: [assert_has_title, assert_has_content]}
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
        creator: {should: true, response: 302, asserts: [assert_photo_identifier, assert_has_photo]}
      }
    )
    define_test(hash, :destroy, options: {analytics: stats_opt('questions', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('questions', 'trash_success')})
    define_test(hash, :move)
    define_test(
      hash, :move!,
      options: {attributes: {forum_id: :forum_move_to}},
      user_types: user_types[:move!].merge(
        staff: {should: true, response: 302, asserts: [
          assert_motions_forum_changed, assert_has_no_motions
        ]}
      )
    )
    define_test(
      hash,
      :move!,
      case_suffix: ' with motions',
      options: {attributes: {forum_id: :forum_move_to, include_motions: '1'}},
      user_types: {staff: {should: true, response: 302, asserts: [
        assert_not_motions_forum_changed, assert_has_five_motions
      ]}}
    )
  end
end
