# frozen_string_literal: true
require 'test_helper'

module Oauth
  class ApplicationsTest < ActionDispatch::IntegrationTest
    define_freetown
    subject do
      Doorkeeper::Application.create(name: 'Name', owner: Profile.community, redirect_uri: 'https://example.com')
    end

    ####################################
    # As Guest
    ####################################
    test 'guest should not index applications' do
      get oauth_applications_path
      assert_not_authorized
    end

    test 'guest should not create applications' do
      assert_no_difference('Doorkeeper::Application.count') do
        post oauth_applications_path,
             params: {doorkeeper_application: {name: 'Name', redirect_uri: 'https://example.com'}}
        assert_not_authorized
      end
    end

    test 'guest should not new applications' do
      get new_oauth_application_path
      assert_not_authorized
    end

    test 'guest should not edit applications' do
      get edit_oauth_application_path(subject)
      assert_not_authorized
    end

    test 'guest should not show applications' do
      get oauth_application_path(subject)
      assert_not_authorized
    end

    test 'guest should not update applications' do
      put oauth_application_path(subject), params: {doorkeeper_application: {name: 'New name'}}
      assert_not_authorized
      assert_equal subject.reload.name, 'Name'
    end

    test 'guest should not destroy applications' do
      subject
      assert_no_difference('Doorkeeper::Application.count') do
        delete oauth_application_path(subject)
        assert_not_authorized
      end
    end

    ####################################
    # As User
    ####################################
    let(:user) { create(:user) }

    test 'user should not index applications' do
      sign_in user
      get oauth_applications_path
      assert_not_authorized
    end

    test 'user should not create applications' do
      sign_in user
      assert_no_difference('Doorkeeper::Application.count') do
        post oauth_applications_path,
             params: {doorkeeper_application: {name: 'Name', redirect_uri: 'https://example.com'}}
        assert_not_authorized
      end
    end

    test 'user should not new applications' do
      sign_in user
      get new_oauth_application_path
      assert_not_authorized
    end

    test 'user should not edit applications' do
      sign_in user
      get edit_oauth_application_path(subject)
      assert_not_authorized
    end

    test 'user should not show applications' do
      sign_in user
      get oauth_application_path(subject)
      assert_not_authorized
    end

    test 'user should not update applications' do
      sign_in user
      put oauth_application_path(subject), params: {doorkeeper_application: {name: 'New name'}}
      assert_not_authorized
      assert_equal subject.reload.name, 'Name'
    end

    test 'user should not destroy applications' do
      sign_in user
      subject
      assert_no_difference('Doorkeeper::Application.count') do
        delete oauth_application_path(subject)
        assert_not_authorized
      end
    end

    ####################################
    # As Staff
    ####################################
    let(:staff) { create(:user, :staff) }

    test 'staff should index applications' do
      sign_in staff
      get oauth_applications_path
      assert_response 200
    end

    test 'staff should create applications' do
      sign_in staff
      assert_difference('Doorkeeper::Application.count') do
        post oauth_applications_path,
             params: {doorkeeper_application: {name: 'Name', redirect_uri: 'https://example.com'}}
        assert_redirected_to oauth_application_path(Doorkeeper::Application.last)
      end
    end

    test 'staff should new applications' do
      sign_in staff
      get new_oauth_application_path
      assert_response 200
    end

    test 'staff should edit applications' do
      sign_in staff
      get edit_oauth_application_path(subject)
      assert_response 200
    end

    test 'staff should show applications' do
      sign_in staff
      get oauth_application_path(subject)
      assert_response 200
    end

    test 'staff should update applications' do
      sign_in staff
      put oauth_application_path(subject), params: {doorkeeper_application: {name: 'New name'}}
      assert_redirected_to oauth_application_path(subject)
      assert_equal subject.reload.name, 'New name'
    end

    test 'staff should destroy applications' do
      subject
      sign_in staff
      assert_difference('Doorkeeper::Application.count', -1) do
        delete oauth_application_path(subject)
        assert_redirected_to oauth_applications_path
      end
    end
  end
end
