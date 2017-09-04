# frozen_string_literal: true

require 'test_helper'

class MediaObjectsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:media_object) { create(:media_object, about: motion) }
  let(:image_object) { create(:image_object, about: motion) }

  ####################################
  # As Guest
  ####################################
  test 'Guest should get show MediaObject' do
    get media_object_path(media_object, format: :json_api)

    assert_response 200
    assert_equal 'schema:MediaObject', parsed_body['data']['attributes']['@type']
  end

  test 'Guest should get show ImageObject' do
    get media_object_path(image_object, format: :json_api)

    assert_response 200
    assert_equal 'schema:ImageObject', parsed_body['data']['attributes']['@type']
  end
end
