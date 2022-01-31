# frozen_string_literal: true

require 'test_helper'

class FormsControllerTest < ActionController::TestCase
  define_page

  ####################################
  # Show
  ####################################
  test 'should include footer group when present' do
    get :show, params: {format: :nq, id: :motions}
    assert_response :success

    footer_group = expect_triple(nil, NS.form[:footerGroup], nil).first
    expect_triple(footer_group.object, RDF.type, NS.form[:FooterGroup])
  end

  test 'should not include footer group when not present' do
    get :show, params: {format: :nq, module: 'linked_rails/auth', id: :sessions}
    assert_response :success

    refute_triple(nil, NS.form[:footerGroup], nil)
  end
end
