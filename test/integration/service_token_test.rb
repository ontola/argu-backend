# frozen_string_literal: true

require 'test_helper'

class ServiceTokenTest < ActionDispatch::IntegrationTest
  define_freetown

  ####################################
  # As Service
  ####################################
  test 'service should use service_token from internal ip' do
    sign_in :service

    get freetown, headers: argu_headers(accept: :nq)

    assert_response 200
  end

  test 'service should not use service_token from external ip' do
    sign_in :service

    assert_raises(RuntimeError) do
      get freetown, headers: argu_headers(accept: :nq).merge('x-forwarded-for': '123.123.123.123')
    end
  end
end
