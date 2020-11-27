# frozen_string_literal: true

require 'test_helper'

class MediaObjectsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:media_object) { create(:media_object, about: motion) }
  let(:image_object) { create(:image_object, about: motion) }
  let(:profile_photo) { create(:profile_photo, about: user) }

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

    get resource_iri(user.default_profile_photo, root: argu), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS::SCHEMA[:ImageObject].to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get html redirect original version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.url_for_version('content') },
        headers: argu_headers(accept: :html)

    assert_redirected_to path_with_hostname("/photos/#{profile_photo.id}/profile_photo.png").sub('http:', 'https:')
  end

  test 'Guest should get html redirect box version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.url_for_version('box') },
        headers: argu_headers(accept: :html)

    assert_redirected_to path_with_hostname("/photos/#{profile_photo.id}/box_profile_photo.jpg").sub('http:', 'https:')
  end

  test 'Guest should get rdf redirect original version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.url_for_version('content') }
    assert_response :success

    expect_triple(
      requested_iri,
      NS::OWL.sameAs,
      RDF::URI(path_with_hostname("/photos/#{profile_photo.id}/profile_photo.png").sub('http:', 'https:'))
    )
  end

  test 'Guest should get rdf redirect box version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.url_for_version('box') }
    assert_response :success

    expect_triple(
      requested_iri,
      NS::OWL.sameAs,
      RDF::URI(path_with_hostname("/photos/#{profile_photo.id}/box_profile_photo.jpg").sub('http:', 'https:'))
    )
  end
end
