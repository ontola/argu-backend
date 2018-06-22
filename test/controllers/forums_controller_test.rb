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
    expect_included(collection_iri(holland, :motions))
    expect_included(collection_iri(holland, :motions, page: 1, type: 'paginated'))
    expect_included(holland.motions.untrashed.map(&:iri))
    expect_not_included(holland.questions.last.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))

    expect_relationship('questionCollection')
    expect_included(collection_iri(holland, :questions))
    expect_included(collection_iri(holland, :questions, page: 1, type: 'paginated'))
    expect_included(holland.questions.untrashed.map(&:iri))
    expect_not_included(holland.questions.trashed.map(&:iri))
  end
end
