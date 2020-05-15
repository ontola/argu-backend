# frozen_string_literal: true

require 'test_helper'

class ContainerNodesControllerTest < ActionController::TestCase
  define_page
  define_holland

  ####################################
  # Show
  ####################################
  test 'should get show forum' do
    tenant_from(holland)
    get :show, params: {format: :json_api, id: holland.url}
    assert_response 200

    expect_relationship('motion_collection')
    expect_relationship('question_collection')
  end
end
