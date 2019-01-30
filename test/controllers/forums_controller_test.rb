# frozen_string_literal: true

require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  define_holland

  ####################################
  # Show
  ####################################
  test 'should get show forum' do
    get :show, params: {format: :json_api, root_id: holland.parent.url, id: holland.url}
    assert_response 200

    expect_relationship('motionCollection')
    expect_relationship('questionCollection')
  end
end
