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
      post freetown.collection_iri(:widgets), params: {
        widget: {
          resource_iri: argu_url,
          primary_resource_id: freetown.uuid,
          permitted_action_title: 'forum_show',
          size: 3,
          widget_type: :deku
        }
      }, headers: argu_headers(accept: :n3)
    end

    assert_response 201
  end
end
