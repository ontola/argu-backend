require 'test_helper'

class ProjectsIntegrationTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  let(:project) { create(:project) }

  test 'should map group or usernames to stairs' do

    patch project_path(project),
          project: {
            title: 'Project Omega',
            content: 'NULL AND (DE)VOID',
            stepups_attributes: {
              '1452960350008': {
                manager: 'commission x'
              },
              '1452960354584': {
                manager: 'mayor'
              },
              trashed_at: 0
            }
          }

    assert_response 302
    json = JSON.parse(response.body)

    assert json
  end

end
