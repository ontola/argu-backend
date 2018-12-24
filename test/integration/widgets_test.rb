# frozen_string_literal: true

require 'test_helper'

class WidgetsTest < ActionDispatch::IntegrationTest
  define_freetown

  ####################################
  # As Service
  ####################################
  test 'service should post create widget' do
    sign_in :service

    assert_difference('Widget.count' => 1) do
      post collection_iri_path(freetown, :widgets), params: {
        widget: {
          resource_iri: argu_url,
          size: 3,
          widget_type: :deku
        }
      }, headers: argu_headers(accept: :n3)
    end

    assert_response 201
  end
end
