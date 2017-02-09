# frozen_string_literal: true
require 'test_helper'

class CorsAccessTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }

  test 'CloudFront should OPTIONS assets cross-origin' do
    options ActionController::Base.helpers.asset_path('application.css'),
            headers: {
              Host: 'https://argu.co',
              Origin: 'https://d3hv9pr8szmavn.cloudfront.net',
              'Access-Control-Request-Method': 'GET',
              'Access-Control-Request-Headers': 'X-Requested-With'
            }

    assert_equal 'https://d3hv9pr8szmavn.cloudfront.net',
                 response.headers['Access-Control-Allow-Origin']
    assert_equal 'GET, OPTIONS',
                 response.headers['Access-Control-Allow-Methods']
  end

  test 'CloudFront should GET assets cross-origin' do
    get ActionController::Base.helpers.asset_path('application.css'),
        headers: {
          Host: 'https://argu.co',
          Origin: 'https://d3hv9pr8szmavn.cloudfront.net',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'X-Requested-With'
        }

    assert_equal 'https://d3hv9pr8szmavn.cloudfront.net',
                 response.headers['Access-Control-Allow-Origin']
  end

  test 'CloudFront should not GET non-assets cross-origin' do
    get motion_path(5),
        headers: {
          Host: 'https://argu.co',
          Origin: 'https://d3hv9pr8szmavn.cloudfront.net',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'X-Requested-With'
        }

    assert_equal nil, response.headers['Access-Control-Allow-Origin']
  end

  test 'CloudFront should not OPTIONS non-assets cross-origin' do
    rescued = false
    begin
      options motion_path(5),
              headers: {
                Host: 'https://argu.co',
                Origin: 'https://d3hv9pr8szmavn.cloudfront.net',
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'X-Requested-With'
              }
    rescue ActionController::RoutingError
      rescued = true
    end

    assert rescued
  end

  ####################################
  # As Guest
  ####################################
  test 'Guest should OPTIONS cross-origin' do
    options motion_path(5),
            headers: {
              Host: 'https://argu.co',
              Origin: 'https://beta.argu.co',
              'Access-Control-Request-Method': 'POST',
              'Access-Control-Request-Headers': 'origin, X-Requested-With'
            }

    assert_equal 'https://beta.argu.co',
                 response.headers['Access-Control-Allow-Origin']
    assert_equal 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
                 response.headers['Access-Control-Allow-Methods']
  end
end
