# frozen_string_literal: true

require 'test_helper'

class ConArgumentsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:argument) { create(:argument, :with_comments, parent: motion) }
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:linked_record) do
    lr = LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid)
    create(:argument, :with_comments, parent: lr)
    create(:argument, :with_comments, parent: lr, pro: false)
    create(:argument, :with_comments, parent: lr, trashed_at: Time.current)
    lr
  end

  ####################################
  # Show
  ####################################
  test 'should get show argument' do
    get :show, params: {format: :json_api, root_id: argu.url, id: argument.fragment}
    assert_redirected_to argument.iri_path
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index arguments of motion with' do
    get :index, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment}
    assert_response 200

    expect_relationship('partOf')

    expect_default_view
    expect_included(collection_iri(motion, :con_arguments, page: 1, type: 'paginated'))
    expect_included(motion.con_arguments.untrashed.map(&:iri))
    expect_not_included(motion.con_arguments.trashed.map(&:iri))
    expect_not_included(motion.pro_arguments.trashed.map(&:iri))
    expect_not_included(motion.pro_arguments.map(&:iri))
  end

  test 'should get index arguments of motion with page=1' do
    get :index, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, motion.con_arguments.untrashed.count)
    expect_included(motion.con_arguments.untrashed.map(&:iri))
    expect_not_included(motion.con_arguments.trashed.map(&:iri))
    expect_not_included(motion.pro_arguments.trashed.map(&:iri))
    expect_not_included(motion.pro_arguments.map(&:iri))
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index arguments of linked_record' do
    get :index, params: linked_record.iri_opts.merge(format: :json_api)
    assert_response 200

    expect_relationship('partOf')

    expect_view_members(expect_default_view, 1)
    expect_included(collection_iri(linked_record, :con_arguments, page: 1, type: :paginated))
    expect_not_included(collection_iri(linked_record, :pro_arguments, page: 1, type: :paginated))
    expect_included(linked_record.con_arguments.untrashed.map(&:iri))
    expect_not_included(linked_record.pro_arguments.trashed.map(&:iri))
    expect_not_included(linked_record.pro_arguments.map(&:iri))
  end

  test 'should get index arguments of linked_record with page=1' do
    get :index, params: linked_record.iri_opts.merge(format: :json_api, type: 'paginated', page: 1)
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, linked_record.con_arguments.untrashed.count)
    expect_included(linked_record.con_arguments.untrashed.map(&:iri))
    expect_not_included(linked_record.pro_arguments.trashed.map(&:iri))
    expect_not_included(linked_record.pro_arguments.map(&:iri))
  end

  #######################################
  # Index for non persisted LinkedRecord
  #######################################
  test 'should get index arguments of non_persisted_linked_record' do
    get :index, params: non_persisted_linked_record.iri_opts.merge(format: :json_api)
    assert_response 200

    expect_relationship('partOf')

    expect_view_members(expect_default_view, 0)
    expect_included(
      collection_iri(non_persisted_linked_record, :con_arguments, page: 1, type: :paginated)
    )
    expect_not_included(
      collection_iri(non_persisted_linked_record, :pro_arguments, page: 1, type: :paginated)
    )
  end
end
