# frozen_string_literal: true

require 'test_helper'

class MediaObjectsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:media_object) { create(:media_object, about: motion) }
  let(:image_object) { create(:image_object, about: motion) }

  ####################################
  # As Guest
  ####################################
  test 'Guest should get show MediaObject' do
    sign_in :guest_user

    get resource_iri(media_object), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS::SCHEMA[:MediaObject].to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get show ImageObject' do
    sign_in :guest_user

    get resource_iri(image_object), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS::SCHEMA[:ImageObject].to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get show user profile photo' do
    sign_in :guest_user

    get resource_iri(user.profile.default_profile_photo, root: argu), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS::SCHEMA[:ImageObject].to_s, primary_resource['attributes']['type']
  end
end
