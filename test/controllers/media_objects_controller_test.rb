# frozen_string_literal: true

require 'test_helper'

class MediaObjectsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_attachments, parent: freetown) }
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
    get :index, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment}
    assert_response 200

    expect_relationship('partOf')

    expect_default_view
    expect_included(
      collection_iri(motion, :media_objects, 'filter%5B%5D' => 'used_as=attachment', page: 1, type: 'paginated')
    )
    expect_included(motion.media_objects.where(used_as: :attachment).map(&:iri))
  end

  test 'should get index media_objects of motion page 1' do
    get :index, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, motion.media_objects.where(used_as: :attachment).count)
    expect_included(motion.media_objects.where(used_as: :attachment).map(&:iri))
  end
end
