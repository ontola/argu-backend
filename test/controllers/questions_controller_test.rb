# frozen_string_literal: true

require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, :with_attachments, parent: freetown) }

  ####################################
  # Show
  ####################################
  test 'should get show question' do
    get :show, params: {format: :json_api, root_id: argu.url, id: question.fragment}
    assert_response 200

    expect_relationship('partOf')
    expect_relationship('creator')

    expect_relationship('attachmentCollection', size: 1)
    expect_included(
      collection_iri(question, :media_objects, 'filter%5B%5D' => 'used_as=attachment')
    )
    expect_included(question.attachments.map(&:iri))

    expect_relationship('motionCollection', size: 1)
    expect_included(collection_iri(question, :motions))
    expect_included(collection_iri(question, :motions, page: 1, type: 'paginated'))
    expect_not_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index questions of forum' do
    get :index, params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url}
    assert_response 200

    expect_relationship('partOf')

    expect_default_view
    expect_included(collection_iri(holland, :questions, page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end

  test 'should get index questions of forum page 1' do
    get :index,
        params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, holland.questions.untrashed.count)
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end
end
