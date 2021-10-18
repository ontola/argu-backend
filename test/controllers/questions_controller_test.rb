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

    expect_relationship('parent')
    expect_relationship('creator')

    expect_relationship('attachment_collection', size: 1)

    expect_relationship('motion_collection', size: 1)
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index questions of forum' do
    get :index, params: {format: :json_api, parent_iri: parent_iri_for(holland)}
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(holland.collection_iri(:questions, page: 1))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end

  test 'should get index questions of forum page 1' do
    get :index,
        params: {format: :json_api, parent_iri: parent_iri_for(holland), type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, holland.questions.untrashed.count)
    expect_not_included(holland.questions.trashed.map(&:iri))
  end
end
