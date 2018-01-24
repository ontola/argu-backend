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

    expect_relationship('motionCollection', 1)
    expect_included(argu_url("/f/#{holland.id}/motions", type: 'paginated'))
    expect_included(argu_url("/f/#{holland.id}/motions", page: 1, type: 'paginated'))
    expect_included(holland.motions.where(question_id: nil).untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.where('question_id IS NOT NULL').map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.trashed.map { |m| argu_url("/m/#{m.id}") })

    expect_relationship('questionCollection', 1)
    expect_included(argu_url("/f/#{holland.id}/questions", type: 'paginated'))
    expect_included(argu_url("/f/#{holland.id}/questions", page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map { |q| argu_url("/q/#{q.id}") })
    expect_not_included(holland.questions.trashed.map { |q| argu_url("/q/#{q.id}") })
  end
end
