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

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)

    assert_relationship('attachmentCollection', 1)
    assert_included("/q/#{question.id}/media_objects?filter%5Bused_as%5D=attachment")
    assert_included(question.attachments.map { |r| "/media_objects/#{r.id}" })

    assert_relationship('motionCollection', 1)
    assert_included("/q/#{question.id}/motions")
    assert_included("/q/#{question.id}/motions?page=1")
    assert_included(question.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(question.motions.trashed.map { |m| "/m/#{m.id}" })
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index questions of forum' do
    get :index, params: {format: :json_api, forum_id: holland.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/f/#{holland.id}/questions?page=1")
    assert_included(holland.questions.untrashed.map { |q| "/q/#{q.id}" })
    assert_not_included(holland.questions.trashed.map { |q| "/q/#{q.id}" })
  end

  test 'should get index questions of forum page 1' do
    get :index, params: {format: :json_api, forum_id: holland.id, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', holland.questions.untrashed.count)
    assert_included(holland.questions.untrashed.map { |q| "/q/#{q.id}" })
    assert_not_included(holland.questions.trashed.map { |q| "/q/#{q.id}" })
  end
end
