# frozen_string_literal: true

require 'test_helper'

class ArgumentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:linked_record) { LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:motion) do
    create(:motion,
           :with_follower,
           parent: freetown,
           creator: create(:user,
                           :follows_reactions_directly,
                           :viewed_notifications_hour_ago)
                      .profile)
  end

  test 'user should post create pro json_api' do
    sign_in user
    motion

    assert_difference('ProArgument.count' => 1, 'Edge.count' => 1) do
      general_create_json(motion)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ProArgument)
  end

  test 'user should post create con json_api' do
    sign_in user
    motion

    assert_difference('ConArgument.count' => 1, 'Edge.count' => 1) do
      general_create_json(motion, false)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ConArgument)
  end

  test 'user should post create pro json_api for linked record' do
    linked_record
    sign_in user

    assert_difference('ProArgument.count' => 1, 'Edge.count' => 1) do
      general_create_json(linked_record)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ProArgument)
  end

  test 'user should post create con json_api for linked record' do
    linked_record
    sign_in user

    assert_difference('ConArgument.count' => 1, 'Edge.count' => 1) do
      general_create_json(linked_record, false)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ConArgument)
  end

  test 'user should post create pro json_api for non-persisted linked record' do
    sign_in user

    diff = {'ProArgument.count' => 1, 'LinkedRecord.count' => 1, 'VoteEvent.count' => 1, 'Edge.count' => 3}
    assert_difference(diff) do
      general_create_json(non_persisted_linked_record)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ProArgument)
  end

  test 'user should post create con json_api for non-persisted linked record' do
    sign_in user

    diff = {'ConArgument.count' => 1, 'LinkedRecord.count' => 1, 'VoteEvent.count' => 1, 'Edge.count' => 3}
    assert_difference(diff) do
      general_create_json(non_persisted_linked_record, false)
    end

    assert_response 201
    assert assigns(:create_service).resource.is_a?(ConArgument)
  end

  private

  def general_create_json(parent, pro = true)
    post collection_iri_path(parent, "#{pro ? 'pro' : 'con'}_arguments"),
         params: {
           data: {
             type: "#{pro ? 'pro' : 'con'}Arguments",
             attributes: {
               pro: pro,
               name: 'Argument title'
             }
           }
         },
         headers: argu_headers(accept: :json_api)
  end
end
