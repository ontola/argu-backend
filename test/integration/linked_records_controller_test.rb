# frozen_string_literal: true
require 'test_helper'

class LinkedRecordsControllerTest < ActionDispatch::IntegrationTest
  define_public_source
  let!(:linked_record) do
    linked_record_mock(1)
    create(:linked_record, source: public_source, iri: 'https://iri.test/resource/1')
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get show unregistered iri' do
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_records_path(iri: 'https://iri.invalid/resource/2')
    end

    assert_response 404
  end

  test 'guest should get show new iri' do
    linked_record_mock(2)
    assert_differences([['LinkedRecord.count', 1], ['Edge.count', 1]]) do
      get linked_records_path(iri: 'https://iri.test/resource/2')
    end

    assert_redirected_to linked_record_path(LinkedRecord.last)
  end

  test 'guest should get show existing iri' do
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_records_path(iri: linked_record.iri)
    end

    assert_redirected_to linked_record_path(linked_record)
  end

  test 'guest should get show id' do
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_record_path(linked_record)
    end

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show unregistered iri' do
    sign_in user
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_records_path(iri: 'https://iri.invalid/resource/2')
    end

    assert_response 404
  end

  test 'user should get show new iri' do
    sign_in user
    linked_record_mock(2)
    assert_differences([['LinkedRecord.count', 1], ['Edge.count', 1]]) do
      get linked_records_path(iri: 'https://iri.test/resource/2')
    end

    assert_redirected_to linked_record_path(LinkedRecord.last)
  end

  test 'user should get show existing iri' do
    sign_in user
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_records_path(iri: linked_record.iri)
    end

    assert_redirected_to linked_record_path(linked_record)
  end

  test 'user should get show id' do
    sign_in user
    assert_differences([['LinkedRecord.count', 0], ['Edge.count', 0]]) do
      get linked_record_path(linked_record)
    end

    assert_response 200
  end
end
