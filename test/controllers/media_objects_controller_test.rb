# frozen_string_literal: true

require 'test_helper'

class MediaObjectsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_attachments, parent: freetown.edge) }
  let(:media_object) { motion.attachments.first }

  ####################################
  # Show
  ####################################
  test 'should get show media_object' do
    get :show, params: {format: :json_api, id: media_object.id}
    assert_response 200
  end

  ####################################
  # Index for Motion
  ####################################
  test 'should get index media_objects of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    expect_relationship('parent', 1)

    expect_relationship('viewSequence', 1)
    expect_included(
      argu_url("/m/#{motion.id}/media_objects", filter: {used_as: :attachment}, page: 1, type: 'paginated')
    )
    expect_included(motion.media_objects.map { |m| argu_url("/media_objects/#{m.id}") })
  end

  test 'should get index media_objects of motion page 1' do
    get :index, params: {format: :json_api, motion_id: motion.id, page: 1}
    assert_response 200

    expect_relationship('parent', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 motion.media_objects.count
    expect_included(motion.media_objects.map { |m| argu_url("/media_objects/#{m.id}") })
  end
end
