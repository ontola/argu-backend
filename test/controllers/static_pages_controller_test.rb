require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  EXCLUDED_METHODS = [:modern, :how_argu_works, :persist_cookie]

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


  ####################################
  # As staff
  ####################################
  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }

  test 'should get activity feed' do
    activities = []
    %i(t_question t_motion t_argument t_comment t_vote).each do |trait|
      activities << FactoryGirl.create(:activity, trait, forum: holland)
    end
    sign_in users(:user_thom)
    create_member(holland, users(:user_thom))

    get :home

    assert_response 200
    assert_equal activities, activities & assigns(:activities)
  end

end
