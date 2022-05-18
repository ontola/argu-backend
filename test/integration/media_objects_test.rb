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
    assert_equal NS.schema.MediaObject.to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get show ImageObject' do
    sign_in :guest_user

    get resource_iri(image_object), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS.schema.ImageObject.to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get show user profile photo' do
    sign_in :guest_user

    get resource_iri(user.default_profile_photo, root: argu), headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal NS.schema.ImageObject.to_s, primary_resource['attributes']['type']
  end

  test 'Guest should get html redirect original version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.public_url_for_version('content') },
        headers: argu_headers(accept: :html)

    assert_redirect_to_active_storage(:content)
  end

  test 'Guest should get html redirect box version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.public_url_for_version('box') },
        headers: argu_headers(accept: :html)

    assert_redirect_to_active_storage(:box, 'profile_photo.jpeg')
  end

  test 'Guest should get rdf redirect original version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.public_url_for_version('content') }
    assert_response :success

    assert_active_storage_triple(:content)
  end

  test 'Guest should get rdf redirect box version of image' do
    sign_in :guest_user

    get ActsAsTenant.with_tenant(argu) { profile_photo.public_url_for_version('box') }
    assert_response :success

    assert_active_storage_triple(:box, 'profile_photo.jpeg')
  end

  private

  def assert_active_storage_triple(version, filename = 'profile_photo.png')
    triple = expect_triple(
      requested_iri,
      NS.owl.sameAs,
      nil
    ).first
    assert_equal triple.object.to_s[0...400], private_url(version)
    assert triple.object.to_s.end_with?(filename)
  end

  def assert_redirect_to_active_storage(version, filename = 'profile_photo.png')
    assert_response :redirect
    assert_equal @response.location[0...400], private_url(version)
    assert @response.location.end_with?(filename)
  end

  def active_storage_iri
    'http://argu.localtest/argu/rails/active_storage/disk/'
  end

  def private_url(version)
    ActsAsTenant.with_tenant(argu) do
      profile_photo.private_url_for_version(version).to_s[0...400]
    end
  end
end
