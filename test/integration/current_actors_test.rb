# frozen_string_literal: true

require 'test_helper'

class CurrentActorsTest < ActionDispatch::IntegrationTest
  define_page
  let(:user) { create(:user) }

  test 'guest should get show current actor' do
    get "/#{argu.url}#{current_actor_path}", headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data'],
                 'id' => "#{Rails.application.config.origin}/#{argu.url}/sessions/#{session.id}", 'type' => 'guestUsers'
    assert_equal JSON.parse(response.body)['data']['relationships']['actor']['data'],
                 'id' => "#{Rails.application.config.origin}/#{argu.url}/sessions/#{session.id}", 'type' => 'guestUsers'
  end

  test 'user should get show current actor' do
    sign_in user

    get "/#{argu.url}#{current_actor_path}", headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data']['id'],
                 "http://#{Rails.application.config.host_name}/#{argu.url}/u/#{user.url}"
    assert_equal JSON.parse(response.body)['data']['relationships']['actor']['data']['id'],
                 "http://#{Rails.application.config.host_name}/#{argu.url}/u/#{user.url}"
  end
end
