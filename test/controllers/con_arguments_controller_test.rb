# frozen_string_literal: true

require 'test_helper'

class ConArgumentsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
  let(:linked_record) do
    lr = LinkedRecord.create_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid)
    create(:argument, :with_comments, parent: lr.edge)
    create(:argument, :with_comments, parent: lr.edge, pro: false)
    create(:argument, :with_comments, parent: lr.edge, edge_attributes: {trashed_at: Time.current})
    lr
  end
  let(:non_persisted_linked_record_base) { non_persisted_linked_record.iri.to_s.gsub('/od/', '/lr/') }
  let(:linked_record_base) { linked_record.iri.to_s.gsub('/od/', '/lr/') }

  ####################################
  # Show
  ####################################
  test 'should get show argument' do
    get :show, params: {format: :json_api, id: argument}
    assert_redirected_to pro_argument_path(argument, format: :json_api)
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index arguments of motion with' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/m/#{motion.id}/cons", page: 1, type: 'paginated'))
    expect_included(motion.con_arguments.untrashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(motion.con_arguments.trashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(motion.pro_arguments.trashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_not_included(motion.pro_arguments.map { |a| argu_url("/pro/#{a.id}") })
  end

  test 'should get index arguments of motion with page=1' do
    get :index, params: {format: :json_api, motion_id: motion.id, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 motion.con_arguments.untrashed.count
    expect_included(motion.con_arguments.untrashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(motion.con_arguments.trashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(motion.pro_arguments.trashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_not_included(motion.pro_arguments.map { |a| argu_url("/pro/#{a.id}") })
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index arguments of linked_record' do
    get :index, params: linked_record.iri_opts.merge(format: :json_api)
    assert_response 200

    expect_relationship('partOf', 1)

    view_sequence = expect_relationship('viewSequence')
    assert_equal expect_included(view_sequence['data']['id'])['relationships']['members']['data'].count, 1
    expect_included("#{linked_record_base}/cons?page=1&type=paginated")
    expect_not_included("#{linked_record_base}/pros?page=1&type=paginated")
    expect_included(linked_record.con_arguments.untrashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(linked_record.pro_arguments.trashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_not_included(linked_record.pro_arguments.map { |a| argu_url("/pro/#{a.id}") })
  end

  test 'should get index arguments of linked_record with page=1' do
    get :index, params: linked_record.iri_opts.merge(format: :json_api, page: 1)
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 linked_record.con_arguments.untrashed.count
    expect_included(linked_record.con_arguments.untrashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(linked_record.pro_arguments.trashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_not_included(linked_record.pro_arguments.map { |a| argu_url("/pro/#{a.id}") })
  end

  #######################################
  # Index for non persisted LinkedRecord
  #######################################
  test 'should get index arguments of non_persisted_linked_record' do
    get :index, params: non_persisted_linked_record.iri_opts.merge(format: :json_api)
    assert_response 200

    expect_relationship('partOf', 1)

    view_sequence = expect_relationship('viewSequence')
    assert_equal expect_included(view_sequence['data']['id'])['relationships']['members']['data'].count, 1
    expect_included("#{non_persisted_linked_record_base}/cons?page=1&type=paginated")
    expect_not_included("#{non_persisted_linked_record_base}/pros?page=1&type=paginated")
  end
end
