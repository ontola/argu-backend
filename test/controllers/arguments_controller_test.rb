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

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)

    assert_relationship('commentCollection', 1)
    assert_included("/a/#{argument.id}/c")
    assert_included("/a/#{argument.id}/c?page=1")
    assert_included(argument.comment_threads.untrashed.map { |c| "/comments/#{c.id}" })
    assert_not_included(argument.comment_threads.trashed.map { |c| "/comments/#{c.id}" })
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index arguments of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 2)
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=yes")
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=no")
    assert_included(motion.arguments.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of motion with option=yes' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'yes'}}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=yes&page=1")
    assert_included(motion.arguments.pro.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.con.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of motion with option=yes and page=1' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'yes'}, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', motion.arguments.pro.untrashed.count)
    assert_included(motion.arguments.pro.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.con.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of motion with option=no' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'no'}}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=no&page=1")
    assert_included(motion.arguments.con.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.pro.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of motion with option=no and page=1' do
    get :index, params: {format: :json_api, motion_id: motion.id, filter: {option: 'no'}, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', motion.arguments.con.untrashed.count)
    assert_included(motion.arguments.con.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.pro.map { |a| "/a/#{a.id}" })
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index arguments of linked_record' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 2)
    assert_included("/lr/#{linked_record.id}/arguments?filter%5Boption%5D=yes")
    assert_included("/lr/#{linked_record.id}/arguments?filter%5Boption%5D=no")
    assert_included(linked_record.arguments.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.trashed.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of linked_record with option=yes' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'yes'}}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/lr/#{linked_record.id}/arguments?filter%5Boption%5D=yes&page=1")
    assert_included(linked_record.arguments.pro.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.con.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of linked_record with option=yes and page=1' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'yes'}, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', linked_record.arguments.pro.untrashed.count)
    assert_included(linked_record.arguments.pro.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.con.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of linked_record with option=no' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'no'}}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/lr/#{linked_record.id}/arguments?filter%5Boption%5D=no&page=1")
    assert_included(linked_record.arguments.con.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.pro.map { |a| "/a/#{a.id}" })
  end

  test 'should get index arguments of linked_record with option=no and page=1' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id, filter: {option: 'no'}, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', linked_record.arguments.con.untrashed.count)
    assert_included(linked_record.arguments.con.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.trashed.map { |a| "/a/#{a.id}" })
    assert_not_included(linked_record.arguments.pro.map { |a| "/a/#{a.id}" })
  end
end
