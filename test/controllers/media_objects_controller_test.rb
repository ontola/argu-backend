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
    get :index, params: {format: :json_api, parent_iri: parent_iri_for(motion), used_as: :attachment}
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(collection_iri(motion, :attachments, page: 1))
  end

  test 'should get index media_objects of motion page 1' do
    get :index, params: {
      format: :json_api,
      parent_iri: parent_iri_for(motion),
      used_as: :attachment,
      type: 'paginated',
      page: 1
    }
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, motion.media_objects.where(used_as: :attachment).count)
  end
end
