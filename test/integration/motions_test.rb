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
  let(:question_requires_location) do
    create(:question,
           :with_follower,
           parent: freetown.edge,
           require_location: true,
           options: {
             creator: create(:profile_direct_email)
           })
  end
  let(:subject) do
    create(:motion,
           :with_arguments,
           :with_votes,
           publisher: creator,
           parent: question.edge)
  end
  let(:motion_with_placement) do
    create(:motion,
           edge_attributes: {
             placements_attributes: {
               '0' => {
                 lat: 1.0,
                 lon: 1.0,
                 placement_type: 'custom'
               }
             }
           },
           publisher: creator,
           parent: question.edge)
  end

  test 'initiator should show tutorial only on first post create' do
    sign_in initiator

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

  test 'initiator should post create motion with latlon' do
    sign_in initiator

    general_create(
      analytics: stats_opt('motions', 'create_success'),
      results: {should: :true, response: 302},
      parent: :freetown,
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              lat: 1.0,
              lon: 1.0,
              zoom_level: 1,
              placement_type: 'custom'
            }
          }
        }
      },
      differences: [['Motion', 1], ['Placement', 1], ['Place', 1], ['Activity.loggings', 2]]
    )

    assert_equal 1, Motion.last.edge.placements.first.lat
    assert_equal 1, Motion.last.edge.placements.first.lon
    assert_equal 1, Motion.last.edge.placements.first.zoom_level
  end

  test 'initiator should not post create motion without latlon in question requiring location' do
    sign_in initiator

    general_create(
      analytics: stats_opt('motions', 'create_failed'),
      results: {should: false, response: 200},
      parent: :question_requires_location,
      differences: [['Motion', 0], ['Activity.loggings', 0]]
    )
  end

  test 'initiator should not post create motion with empty latlon in question requiring location' do
    sign_in initiator

    general_create(
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              id: '',
              placement_type: 'custom',
              lat: '',
              lon: '',
              zoom_level: '1'
            }
          }
        }
      },
      analytics: stats_opt('motions', 'create_failed'),
      results: {should: false, response: 200},
      parent: :question_requires_location,
      differences: [['Motion', 0], ['Activity.loggings', 0]]
    )
  end

  test 'initiator should post create motion with latlon in question requiring location' do
    sign_in initiator

    general_create(
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              id: '',
              placement_type: 'custom',
              lat:  2.0,
              lon:  2.0,
              zoom_level: '1'
            }
          }
        }
      },
      analytics: stats_opt('motions', 'create_success'),
      results: {should: true, response: 302},
      parent: :question_requires_location,
      differences: [['Motion', 1], ['Activity.loggings', 2]]
    )
  end

  test 'creator should put update motion change latlon' do
    sign_in creator

    general_update(
      results: {should: :true, response: 302},
      record: :motion_with_placement,
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              id: motion_with_placement.edge.placements.first.id,
              lat: 2.0,
              lon: 2.0
            }
          }
        }
      },
      differences: [['Motion', 0], ['Placement', 0], ['Place', 1], ['Activity.loggings', 1]]
    )

    motion_with_placement.edge.reload
    assert_equal 2, motion_with_placement.edge.placements.first.lat
    assert_equal 2, motion_with_placement.edge.placements.first.lon
  end

  test 'creator should put update motion remove latlon' do
    sign_in creator

    general_update(
      results: {should: :true, response: 302},
      record: :motion_with_placement,
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              id: motion_with_placement.edge.placements.first.id,
              _destroy: 'true'
            }
          }
        }
      },
      differences: [['Motion', 0], ['Placement', -1], ['Place', 0], ['Activity.loggings', 1]]
    )
  end
end
