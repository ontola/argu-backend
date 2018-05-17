# frozen_string_literal: true

require 'test_helper'

class QuestionsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  subject { create(:question, parent: freetown.edge) }
  let(:group) { create(:group, parent: argu.edge) }
  let(:reset_motion_grants) { create(:grant_reset, edge: subject.edge, resource_type: 'Motion', action: 'create') }
  let(:create_motion_grant) do
    create(:grant, edge: subject.edge, group_id: group.id, grant_set: GrantSet.for_one_action('Motion', 'create'))
  end

  test 'initiator should post create question with latlon' do
    sign_in initiator

    general_create(
      analytics: stats_opt('questions', 'create_success'),
      results: {should: true, response: 302},
      parent: :freetown,
      attributes: {
        placements_attributes: {
          '0' => {
            lat: 1,
            lon: 1,
            placement_type: 'custom'
          }
        }
      },
      differences: [['Question', 1], ['Placement', 1], ['Place', 1], ['Activity.loggings', 2]]
    )
  end

  test 'administrator should create with grant reset without group_ids' do
    sign_in administrator

    general_create(
      analytics: stats_opt('questions', 'create_success'),
      parent: freetown,
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true,
        create_motion_group_ids: ['']
      },
      differences: [['Question', 1], ['GrantReset', 1], ['Grant', 0]]
    )
  end

  test 'administrator should create with grant reset' do
    sign_in administrator

    general_create(
      analytics: stats_opt('questions', 'create_success'),
      parent: freetown,
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true,
        create_motion_group_ids: [group.id]
      },
      differences: [['Question', 1], ['GrantReset', 1], ['Grant', 1]]
    )
  end

  test 'administrator should set grant reset without group_ids' do
    sign_in administrator

    general_update(
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true
      },
      differences: [['GrantReset', 1], ['Grant', 0]]
    )
  end

  test 'administrator should set grant reset with group_ids' do
    sign_in administrator
    general_update(
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true,
        create_motion_group_ids: [group.id]
      },
      differences: [['GrantReset', 1], ['Grant', 1]]
    )
  end

  test 'administrator should set grant reset with group_ids unchanged' do
    sign_in administrator
    reset_motion_grants
    create_motion_grant
    general_update(
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true,
        create_motion_group_ids: [group.id]
      },
      differences: [['GrantReset', 0], ['Grant', 0]]
    )
  end

  test 'administrator should set grant reset with group_ids remove grants' do
    sign_in administrator
    reset_motion_grants
    create_motion_grant
    assert_equal 1, subject.grants.count
    general_update(
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: true,
        create_motion_group_ids: ['']
      },
      differences: [['GrantReset', 0], ['Grant', -1]]
    )
  end

  test 'administrator update without attributes should leave grant_reset' do
    sign_in administrator
    reset_motion_grants
    create_motion_grant
    general_update(
      results: {should: true, response: 302},
      attributes: {},
      differences: [['GrantReset', 0], ['Grant', 0]]
    )
  end

  test 'administrator should revert grant reset' do
    sign_in administrator
    reset_motion_grants
    create_motion_grant

    general_update(
      results: {should: true, response: 302},
      attributes: {
        reset_create_motion: false
      },
      differences: [['GrantReset', -1], ['Grant', -1]]
    )
  end
end
