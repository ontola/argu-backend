# frozen_string_literal: true

require 'test_helper'

class CorsAccessTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }

  test 'CloudFront should not GET non-assets cross-origin' do
    get expand_uri_template(:motions_iri, id: 5),
        headers: {
          Host: 'https://argu.co',
          Origin: 'https://d3hv9pr8szmavn.cloudfront.net',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'X-Requested-With'
        }

    assert_nil response.headers['Access-Control-Allow-Origin']
  end

  ####################################
  # As Guest
  ####################################
  test 'Guest should OPTIONS assets cross-origin' do
    sign_in :guest_user

    options ActionController::Base.helpers.asset_path('application.css'),
            headers: {
              Host: 'https://argu.co',
              Origin: 'https://argu.co',
              'Access-Control-Request-Method': 'GET',
              'Access-Control-Request-Headers': 'X-Requested-With'
            }

    assert_equal 'https://argu.co',
                 response.headers['Access-Control-Allow-Origin']
    assert_equal 'GET, OPTIONS',
                 response.headers['Access-Control-Allow-Methods']
  end

  test 'Guest should GET assets cross-origin' do
    sign_in :guest_user

    get ActionController::Base.helpers.asset_path('application.css'),
        headers: {
          Host: 'https://argu.co',
          Origin: 'https://argu.co',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'X-Requested-With'
        }

    assert_equal 'https://argu.co',
                 response.headers['Access-Control-Allow-Origin']
  end

  test 'Guest should not OPTIONS non-assets cross-origin' do
    sign_in :guest_user

    options expand_uri_template(:motions_iri, id: 5),
            headers: {
              Host: 'https://argu.co',
              Origin: 'https://argu.co',
              'Access-Control-Request-Method': 'GET',
              'Access-Control-Request-Headers': 'X-Requested-With'
            }
    assert_nil response.headers['Access-Control-Allow-Origin']
    assert_nil response.headers['Access-Control-Allow-Methods']
  end
end
