# frozen_string_literal: true

require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, :with_attachments, parent: freetown.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show question' do
    get :show, params: {format: :json_api, id: question.id}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('attachmentCollection', 1)
    expect_included(argu_url("/q/#{question.id}/media_objects", filter: {used_as: 'attachment'}, type: 'paginated'))
    expect_included(question.attachments.map { |r| argu_url("/media_objects/#{r.id}") })

    expect_relationship('motionCollection', 1)
    expect_included(argu_url("/q/#{question.id}/m", type: 'paginated'))
    expect_included(argu_url("/q/#{question.id}/m", page: 1, type: 'paginated'))
    expect_included(question.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index questions of forum' do
    get :index, params: {format: :json_api, forum_id: holland.id}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/#{holland.url}/q", page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map { |q| argu_url("/q/#{q.id}") })
    expect_not_included(holland.questions.trashed.map { |q| argu_url("/q/#{q.id}") })
  end

  test 'should get index questions of forum page 1' do
    get :index, params: {format: :json_api, forum_id: holland.id, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 holland.questions.untrashed.count
    expect_included(holland.questions.untrashed.map { |q| argu_url("/q/#{q.id}") })
    expect_not_included(holland.questions.trashed.map { |q| argu_url("/q/#{q.id}") })
  end
end
