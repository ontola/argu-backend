# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let(:staff) { create(:user, :staff) }

  test 'staff should post create project' do
    sign_in staff

    general_create(
      attributes: {},
      results: {should: true, response: :created},
      parent: :freetown,
      differences: [
        ['Project', 1],
        ['Phase', 3],
        ['Survey', 1],
        ['Question', 1],
        ['BlogPost', 1],
        ['Activity', 1]
      ]
    )
    expect_phase_resources
  end

  def expect_phase_resources
    project = Project.last
    assert_equal project.phases.first.resource, Survey.last
    assert_equal project.phases.second.resource, Question.last
    assert_equal project.phases.third.resource, BlogPost.last
  end
end
