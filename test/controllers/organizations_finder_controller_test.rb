# frozen_string_literal: true

require 'test_helper'

class OrganizationsFinderControllerTest < ActionController::TestCase
  include UrlHelper

  define_freetown
  define_helsinki
  let(:motion) { create(:motion, parent: freetown) }
  let(:helsinki_motion) { create(:motion, parent: helsinki) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get show organization without iri' do
    get :show, params: {format: :nt}

    assert_response 404
  end

  test 'guest should get show organization of public motion' do
    get :show, params: {iri: motion.iri, format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of new motion iri' do
    get :show, params: {iri: new_iri(freetown, :motions), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of root' do
    get :show, params: {iri: root_path, format: :nt}

    assert_response 404
  end

  test 'guest should get show organization of user' do
    get :show, params: {iri: user_path(User.last), format: :nt}

    assert_response 404
  end

  test 'guest should get show organization of user profile_photo' do
    get :show, params: {iri: media_object_path(User.last.profile.default_profile_photo), format: :nt}

    assert_response 404
  end

  test 'guest should get show organization of page profile_photo' do
    get :show, params: {iri: media_object_path(Page.last.profile.default_profile_photo), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of forum profile_photo' do
    get :show, params: {iri: media_object_path(freetown.default_profile_photo), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of hidden motion' do
    get :show, params: {iri: helsinki_motion.iri, format: :nt}

    assert_response :forbidden
  end

  test 'guest should get show organization of deku iri' do
    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/od/123", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of linked_record' do
    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/lr/123", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should get show organization of linked_record collection' do
    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/lr/123/votes", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'guest should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :nt}

    assert_response 404
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show organization without iri' do
    sign_in user

    get :show, params: {format: :nt}

    assert_response 404
  end

  test 'user should get show organization of public motion' do
    sign_in user

    get :show, params: {iri: motion.iri, format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'user should get show organization of hidden motion' do
    sign_in user

    get :show, params: {iri: helsinki_motion.iri, format: :nt}

    assert_response :forbidden
  end

  test 'user should get show organization of deku iri' do
    sign_in user

    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/od/123", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'user should get show organization of linked_record' do
    sign_in user

    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/lr/123", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'user should get show organization of linked_record collection' do
    sign_in user

    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/lr/123/votes", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'user should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :nt}
    sign_in user

    assert_response 404
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(helsinki) }

  test 'initiator should get show organization of hidden motion' do
    sign_in initiator

    get :show, params: {iri: helsinki_motion.iri, format: :nt}

    assert_response 200
    assert_equal helsinki.root, assigns(:organization)
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should get show organization of motion form' do
    sign_in administrator

    get :show, params: {iri: argu_url("/#{argu.url}/m/#{motion.fragment}/edit", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end

  test 'administrator should get show organization of forum settings' do
    sign_in administrator

    get :show, params: {iri: argu_url("/#{argu.url}/#{freetown.url}/settings", frontend: true), format: :nt}

    assert_response 200
    assert_equal argu, assigns(:organization)
  end
end
