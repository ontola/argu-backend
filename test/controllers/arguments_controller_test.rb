# frozen_string_literal: true

require 'test_helper'

class ArgumentsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  define_public_source
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:linked_record) { create(:linked_record, :with_arguments, :with_votes, source: public_source) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show argument' do
    get :show, params: {format: :json_api, id: argument}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('commentCollection', 1)
    expect_included(argu_url("/a/#{argument.id}/c"))
    expect_included(argu_url("/a/#{argument.id}/c", page: 1))
    expect_included(argument.comment_threads.untrashed.map { |c| argu_url("/comments/#{c.id}") })
    expect_not_included(argument.comment_threads.trashed.map { |c| argu_url("/comments/#{c.id}") })
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index arguments of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 2)
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'yes'}))
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'no'}))
    expect_included(motion.arguments.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of motion with option=yes' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'yes'}}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'yes'}, page: 1))
    expect_included(motion.arguments.pro.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.con.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of motion with option=yes and page=1' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'yes'}, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', motion.arguments.pro.untrashed.count)
    expect_included(motion.arguments.pro.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.con.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of motion with option=no' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'no'}}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'no'}, page: 1))
    expect_included(motion.arguments.con.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.pro.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of motion with option=no and page=1' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'no'}, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', motion.arguments.con.untrashed.count)
    expect_included(motion.arguments.con.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.pro.map { |a| argu_url("/a/#{a.id}") })
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index arguments of linked_record' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 2)
    expect_included(argu_url("/lr/#{linked_record.id}/arguments", filter: {option: 'yes'}))
    expect_included(argu_url("/lr/#{linked_record.id}/arguments", filter: {option: 'no'}))
    expect_included(linked_record.arguments.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of linked_record with option=yes' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'yes'}}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/lr/#{linked_record.id}/arguments", filter: {option: 'yes'}, page: 1))
    expect_included(linked_record.arguments.pro.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.con.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of linked_record with option=yes and page=1' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'yes'}, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', linked_record.arguments.pro.untrashed.count)
    expect_included(linked_record.arguments.pro.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.con.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of linked_record with option=no' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'no'}}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/lr/#{linked_record.id}/arguments", filter: {option: 'no'}, page: 1))
    expect_included(linked_record.arguments.con.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.pro.map { |a| argu_url("/a/#{a.id}") })
  end

  test 'should get index arguments of linked_record with option=no and page=1' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'no'}, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', linked_record.arguments.con.untrashed.count)
    expect_included(linked_record.arguments.con.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(linked_record.arguments.pro.map { |a| argu_url("/a/#{a.id}") })
  end
end
