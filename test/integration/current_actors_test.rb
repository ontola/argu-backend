# frozen_string_literal: true

require 'test_helper'

class CurrentActorsTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user) }

  test 'guest should get show current actor' do
    get "/#{Page.first.url}#{current_actor_path}", headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data'],
                 'id' => "http://127.0.0.1:42000/sessions/#{session.id}", 'type' => 'guestUsers'
    assert_equal JSON.parse(response.body)['data']['relationships']['actor']['data'],
                 'id' => "http://127.0.0.1:42000/sessions/#{session.id}", 'type' => 'guestUsers'
  end

  test 'user should get show current actor' do
    sign_in user

    get "/#{Page.first.url}#{current_actor_path}", headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data']['id'],
                 "http://#{Rails.application.config.host_name}/u/#{user.url}"
    assert_equal JSON.parse(response.body)['data']['relationships']['actor']['data']['id'],
                 "http://#{Rails.application.config.host_name}/u/#{user.url}"
  end
end
