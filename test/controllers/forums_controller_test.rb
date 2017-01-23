# frozen_string_literal: true
require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  define_holland

  ####################################
  # Show
  ####################################
  test 'should get show forum' do
    get :show, params: {format: :json_api, id: holland.id}
    assert_response 200

    assert_relationship('motionCollection', 1)
    assert_included("/f/#{holland.id}/motions")
    assert_included("/f/#{holland.id}/motions?page=1")
    assert_included(holland.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(holland.motions.trashed.map { |m| "/m/#{m.id}" })

    assert_relationship('questionCollection', 1)
    assert_included("/f/#{holland.id}/questions")
    assert_included("/f/#{holland.id}/questions?page=1")
    assert_included(holland.questions.untrashed.map { |q| "/q/#{q.id}" })
    assert_not_included(holland.questions.trashed.map { |q| "/q/#{q.id}" })
  end
end
