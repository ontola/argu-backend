require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  EXCLUDED_METHODS = [:modern, :how_argu_works]

  test 'should get redirect' do
    sign_in users(:user)

    StaticPagesController.public_instance_methods(false).-(EXCLUDED_METHODS).each do |action|
      get action
      assert_response 302, "#{action} doesn't redirect"
    end

  end

  test 'should get how_argu_works' do
    sign_in users(:user)

    get :how_argu_works

    assert_response 200
  end

end
