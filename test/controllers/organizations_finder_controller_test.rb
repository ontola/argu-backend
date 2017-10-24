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
    create(:linked_record, source: public_source, iri: 'https://iri.test/resource/1')
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get show organization without iri' do
    get :show, params: {format: :json_api}

    assert_response 404
  end

  test 'guest should get show organization of public motion' do
    get :show, params: {iri: motion.context_id, format: :json_api}

    assert_response 200
  end

  test 'guest should get show organization of hidden motion' do
    get :show, params: {iri: helsinki_motion.context_id, format: :json_api}

    assert_not_authorized
  end

  test 'guest should get show organization of uninitialized linked_record' do
    linked_record_mock(1, url: 'https://iri.test/resource/1')

    get :show, params: {iri: 'https://iri.test/resource/1', format: :json_api}

    assert_response 200
  end

  test 'guest should get show organization of initialized linked_record' do
    get :show, params: {iri: linked_record.iri, format: :json_api}

    assert_response 200
  end

  test 'guest should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :json_api}

    assert_response 404
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show organization without iri' do
    sign_in user

    get :show, params: {format: :json_api}

    assert_response 404
  end

  test 'user should get show organization of public motion' do
    sign_in user

    get :show, params: {iri: motion.context_id, format: :json_api}

    assert_response 200
  end

  test 'user should get show organization of hidden motion' do
    sign_in user

    get :show, params: {iri: helsinki_motion.context_id, format: :json_api}

    assert_not_authorized
  end

  test 'user should get show organization of uninitialized linked_record' do
    linked_record_mock(1, url: 'https://iri.test/resource/1')
    sign_in user

    get :show, params: {iri: 'https://iri.test/resource/1', format: :json_api}

    assert_response 200
  end

  test 'user should get show organization of initialized linked_record' do
    get :show, params: {iri: linked_record.iri, format: :json_api}
    sign_in user

    assert_response 200
  end

  test 'user should not get show organization of invalid iri' do
    get :show, params: {iri: 'https://iri.invalid/resource/1', format: :json_api}
    sign_in user

    assert_response 404
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(helsinki) }

  test 'member should get show organization of hidden motion' do
    sign_in member

    get :show, params: {iri: helsinki_motion.context_id, format: :json_api}

    assert_response 200
  end
end
