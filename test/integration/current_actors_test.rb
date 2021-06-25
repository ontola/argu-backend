# frozen_string_literal: true

require 'test_helper'

class CurrentActorsTest < ActionDispatch::IntegrationTest
  define_page
  let(:user) { create(:user) }

  test 'guest should get show current actor' do
    sign_in :guest_user

    get "/#{argu.url}/c_a", headers: argu_headers(accept: :json_api)

    id = assigns[:doorkeeper_token].resource_owner_id
    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data'],
                 'id' => "#{Rails.application.config.origin.sub('https', 'http')}/#{argu.url}/sessions/#{id}",
                 'type' => 'guest_user'
  end

  test 'user should get show current actor' do
    sign_in user

    get "/#{argu.url}/c_a", headers: argu_headers(accept: :json_api)

    assert_response 200
    assert_equal JSON.parse(response.body)['data']['relationships']['user']['data']['id'],
                 "#{Rails.application.config.origin.sub('https', 'http')}/#{argu.url}/u/#{user.id}"
  end
end
