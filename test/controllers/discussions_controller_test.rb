require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:helsinki) { FactoryGirl.create(:hidden_populated_forum,
                                       name: 'helsinki',
                                       visible_with_a_link: true) }
  let(:helsinki_key) { FactoryGirl.create(:access_token, item: helsinki) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get new' do
    get :new, forum_id: holland

    assert_response 200
  end

  test 'guest should get new without forum' do
    get :new

    assert_response 200
  end

  ####################################
  # As Spectator
  ####################################
  test 'spectator should get new' do
    get :new, forum_id: helsinki, at: helsinki_key.access_token

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get new' do
    sign_in user

    get :new, forum_id: holland

    assert_response 200
  end

  test 'user should get new for helsinki' do
    sign_in user

    get :new, forum_id: helsinki

    assert_response 404
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(helsinki) }

  test 'member should get new' do
    sign_in member

    get :new, forum_id: holland

    assert_response 200
  end
end
