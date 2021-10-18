# frozen_string_literal: true

require 'test_helper'

class ProArgumentsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:argument) { create(:pro_argument, :with_comments, parent: motion) }

  ####################################
  # Show
  ####################################
  test 'should get show argument' do
    get :show, params: {format: :json_api, root_id: argu.url, id: argument.fragment}
    assert_response 200

    expect_relationship('parent')
    expect_relationship('creator')

    expect_relationship('comment_collection')
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index arguments of motion with' do
    get :index, params: {format: :json_api, parent_iri: parent_iri_for(motion)}
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(motion.collection_iri(:pro_arguments, page: 1))
    expect_not_included(motion.pro_arguments.trashed.map(&:iri))
    expect_not_included(motion.con_arguments.trashed.map(&:iri))
    expect_not_included(motion.con_arguments.map(&:iri))
  end

  test 'should get index arguments of motion with page=1' do
    get :index, params: {format: :json_api, parent_iri: parent_iri_for(motion), type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, motion.pro_arguments.untrashed.count)
    expect_not_included(motion.pro_arguments.trashed.map(&:iri))
    expect_not_included(motion.con_arguments.trashed.map(&:iri))
    expect_not_included(motion.con_arguments.map(&:iri))
  end
end
