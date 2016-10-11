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
        member: {
          should: false,
          response: 200,
          asserts: ['assert_select "#question_title", "Question"',
                    'assert_select "#question_content", "C"']
        }
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
        creator: {
          should: true,
          response: 302,
          asserts: [
            'assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
            'assert_equal 1, resource.photos.count'
          ]
        }
      }
    )
    define_test(hash, :show, asserts: [
                  'assigns(:motions).none? { |motion| motion.is_trashed?}'
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
      options: {attributes: {title: 'Question', content: 'C'}},
      user_types: {
        creator: {
          should: false,
          response: 200,
          asserts: ['assert_select "#question_title", "Question"',
                    'assert_select "#question_content", "C"']
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
          asserts: ['assert_equal "cover_photo.jpg", resource.default_cover_photo.image_identifier',
                    'assert_equal 1, resource.photos.count']
        }
      }
    )
    define_test(hash, :destroy, options: {analytics: stats_opt('questions', 'destroy_success')})
    define_test(hash, :trash, options: {analytics: stats_opt('questions', 'trash_success')})
    define_test(hash, :move)
    define_test(
      hash, :move!,
      options: {attributes: {forum_id: :forum_move_to}},
      user_types: user_types[:move!].merge(staff: {should: true, response: 302, asserts: [
                                             'Motion.pluck(:forum_id).uniq == [freetown.id]',
                                             'assert_equal 0, assigns(:question).motions.count'
                                           ]})
    )
    define_test(
      hash,
      :move!,
      case_suffix: ' with motions',
      options: {attributes: {forum_id: :forum_move_to, include_motions: '1'}},
      user_types: {staff: {should: true, response: 302, asserts: [
        'assigns(:question).motions.pluck(:forum_id).uniq == [assigns(:question).forum_id]',
        'assert_equal 5, assigns(:question).motions.count'
      ]}}
    )
  end
end
