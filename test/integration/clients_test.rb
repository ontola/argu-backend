# frozen_string_literal: true

require 'test_helper'

class ClientsTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user) }

  test 'external service should post create client through SPI' do
    assert_difference('Doorkeeper::Application.count' => 1) do
      post oauth_register_service_client_path,
           params: client_data,
           headers: argu_headers(accept: :json).merge('X-Forwarded-For' => '1.2.3.4')
    end
    assert_response :success

    assert_equal Doorkeeper::Application.last.scopes, %w[]
    assert_equal Doorkeeper::Application.last.owner, User.service
  end

  test 'service should post create client through SPI' do
    assert_difference('Doorkeeper::Application.count' => 1) do
      post oauth_register_service_client_path,
           params: client_data,
           headers: argu_headers(accept: :json)
    end
    assert_response :success

    assert_equal Doorkeeper::Application.last.scopes, %w[service]
    assert_equal Doorkeeper::Application.last.owner, User.service
  end

  private

  def client_data
    {
      client_name: 'Service app',
      redirect_uris: ['https://example.com']
    }
  end
end
