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

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('attachmentCollection', 1)
    expect_included(
      collection_iri(question, :media_objects, CGI.escape('filter[used_as]') => 'attachment', type: 'paginated')
    )
    expect_included(question.attachments.map(&:iri))

    expect_relationship('motionCollection', 1)
    expect_included(collection_iri(question, :motions, type: 'paginated'))
    expect_not_included(collection_iri(question, :motions, page: 1, type: 'paginated'))
    expect_not_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index questions of forum' do
    get :index, params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(collection_iri(holland, :questions, page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end

  test 'should get index questions of forum page 1' do
    get :index, params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 holland.questions.untrashed.count
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end
end
