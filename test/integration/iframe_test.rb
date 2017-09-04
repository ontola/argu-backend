# frozen_string_literal: true

require 'test_helper'

class IframeTest < ActionDispatch::IntegrationTest
  define_freetown

  test 'it sets the meta tag' do
    csrf_token = SecureRandom.urlsafe_base64(20)

    get forum_path(freetown, iframe: 'true'),
        headers: {
          'X-Iframe-Csrf-Token': csrf_token
        }

    assert_response 200
    assert_select("meta[name=\"iframe-csrf-token\"][content=\"#{csrf_token}\"]")
  end
end
