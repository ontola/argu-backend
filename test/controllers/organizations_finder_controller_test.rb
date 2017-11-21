# frozen_string_literal: true

require 'test_helper'

class OrganizationsFinderControllerTest < ActionController::TestCase
  define_freetown
  define_helsinki
  define_public_source
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:helsinki_motion) { create(:motion, parent: helsinki.edge) }
  let(:linked_record) do
    linked_record_mock(1)
    create(:linked_record, source: public_source, record_iri: 'https://iri.test/resource/1')
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get show organization without iri' do
    get :show, params: {format: :n3}

    assert_response 404
  end

  test 'guest should get show organization of public motion' do
    get :show, params: {iri: motion.iri, format: :n3}

    assert_response 200
  end

  test 'guest should get show organization of new motion iri' do
    get :show, params: {iri: new_forum_motion_path(freetown), format: :n3}

    assert_response 200
  end

  test 'guest should get show organization of root' do
    get :show, params: {iri: root_path, format: :n3}

    assert_response 404
  end

  test 'guest should get show organization of user' do
    get :show, params: {iri: user_path(User.last), format: :n3}

    assert_response 404
  end

  test 'guest should get show organization of user profile_photo' do
    get :show, params: {iri: media_object_path(Profile.last.default_profile_photo), format: :n3}

    assert_response 404
  end

  test 'guest should get show organization of forum profile_photo' do
    get :show, params: {iri: media_object_path(freetown.default_profile_photo), format: :n3}

    assert_response 200
  end

  test 'guest should get show organization of hidden motion' do
    get :show, params: {iri: helsinki_motion.iri, format: :n3}

    assert_not_authorized
  end

  test 'guest should get show organization of uninitialized linked_record' do
    linked_record_mock(1, url: 'https://iri.test/resource/1')

    get :show, params: {iri: 'https://iri.test/resource/1', format: :n3}

    assert_response 200
  end

  test 'guest should get show organization of initialized linked_record' do
    get :show, params: {iri: linked_record.record_iri, format: :n3}

    assert_response 200
  end

  test 'guest should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :n3}

    assert_response 404
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show organization without iri' do
    sign_in user

    get :show, params: {format: :n3}

    assert_response 404
  end

  test 'user should get show organization of public motion' do
    sign_in user

    get :show, params: {iri: motion.iri, format: :n3}

    assert_response 200
  end

  test 'user should get show organization of hidden motion' do
    sign_in user

    get :show, params: {iri: helsinki_motion.iri, format: :n3}

    assert_not_authorized
  end

  test 'user should get show organization of uninitialized linked_record' do
    linked_record_mock(1, url: 'https://iri.test/resource/1')
    sign_in user

    get :show, params: {iri: 'https://iri.test/resource/1', format: :n3}

    assert_response 200
  end

  test 'user should get show organization of initialized linked_record' do
    get :show, params: {iri: linked_record.record_iri, format: :n3}
    sign_in user

    assert_response 200
  end

  test 'user should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :n3}
    sign_in user

    assert_response 404
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(helsinki) }

  test 'initiator should get show organization of hidden motion' do
    sign_in initiator

    get :show, params: {iri: helsinki_motion.iri, format: :n3}

    assert_response 200
  end
end
