require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  EXCLUDED_METHODS = [:modern, :how_argu_works, :persist_cookie, :new_discussion]

  let(:user) { create(:user) }

  ####################################
  # As User
  ####################################
  test 'should get redirect' do
    sign_in user

    StaticPagesController.public_instance_methods(false).-(EXCLUDED_METHODS).each do |action|
      get action
      assert_response 302, "#{action} doesn't redirect"
    end
  end

  test 'should get how_argu_works' do
    sign_in user

    get :how_argu_works

    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let!(:freetown) { create(:forum) }
  let(:staff) { create(:user, :staff) }

  test 'should get activity feed' do
    activities = []
    %i(t_question t_motion t_argument t_comment t_vote).each do |trait|
      activities << create(:activity, trait, forum: freetown)
    end
    sign_in staff
    create_member(freetown, staff)

    get :home

    assert_response 200
    assert_equal activities, activities & assigns(:activities)
  end
end
