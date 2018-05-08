# frozen_string_literal: true

require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  define_holland

  ####################################
  # Show
  ####################################
  test 'should get show forum' do
    get :show, params: {format: :json_api, root_id: holland.page.id, id: holland.id}
    assert_response 200

    expect_relationship('motionCollection', 1)
    expect_included(collection_iri(holland, :motions, type: 'paginated'))
    expect_included(collection_iri(holland, :motions, page: 1, type: 'paginated'))
    expect_included(holland.motions.where(question_id: nil).untrashed.map(&:iri))
    expect_not_included(holland.motions.where('question_id IS NOT NULL').map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))

    expect_relationship('questionCollection', 1)
    expect_included(collection_iri(holland, :questions, type: 'paginated'))
    expect_included(collection_iri(holland, :questions, page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end
end
