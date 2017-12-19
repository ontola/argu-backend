# frozen_string_literal: true

require 'test_helper'

class QuestionsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  test 'initiator should post create question with latlon' do
    sign_in initiator

    general_create(
      analytics: stats_opt('questions', 'create_success'),
      results: {should: true, response: 302},
      parent: :freetown,
      attributes: {
        edge_attributes: {
          placements_attributes: {
            '0' => {
              lat: 1,
              lon: 1,
              placement_type: 'custom'
            }
          }
        }
      },
      differences: [['Question', 1], ['Placement', 1], ['Place', 1], ['Activity.loggings', 2]]
    )
  end
end
