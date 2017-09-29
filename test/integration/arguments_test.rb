# frozen_string_literal: true

require 'test_helper'

class ArgumentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  define_public_source
  let(:linked_record) { create(:linked_record, source: public_source, record_iri: 'https://iri.test/resource/1') }
  let(:motion) do
    create(:motion,
           :with_follower,
           parent: freetown.edge,
           creator: create(:user,
                           :follows_reactions_directly,
                           :viewed_notifications_hour_ago)
                      .profile)
  end

  test 'user should post create pro json_api' do
    sign_in user
    motion

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      general_create_json(motion)
    end

    assert_response 201
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create con json_api' do
    sign_in user
    motion

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      general_create_json(motion, false)
    end

    assert_response 201
    assert_not assigns(:create_service).resource.pro?
  end

  test 'user should post create pro json_api for linked record' do
    linked_record_mock(1)
    linked_record_mock(2)
    linked_record
    sign_in user

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      general_create_json(linked_record)
    end

    assert_response 201
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create con json_api for linked record' do
    linked_record_mock(1)
    linked_record_mock(2)
    linked_record
    sign_in user

    assert_differences([['Argument.count', 1], ['Edge.count', 1]]) do
      general_create_json(linked_record, false)
    end

    assert_response 201
    assert_not assigns(:create_service).resource.pro?
  end

  private

  def general_create_json(parent, pro = true)
    post url_for([parent, :arguments]),
         params: {
           format: :json_api,
           data: {
             type: 'arguments',
             attributes: {
               pro: pro,
               name: 'Argument title'
             }
           }
         }
  end
end
