require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  include TestHelper
  include Devise::Test::ControllerHelpers

  define_freetown
  let(:user) { create(:user) }
  let(:place) { create(:place) }
  let(:page) { create(:page) }

  ####################################
  # As Guest
  ####################################

  test 'should post create nl' do
    locale = :nl
    cookies[:locale] = locale.to_s
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_differences([['User.count', 1],
                        ['GroupMembership.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      post :create,
           params: {user: attributes_for(:user)}
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'email')
    end
    assert_equal locale, User.last.language.to_sym
    sign_out :user
    User.last.destroy
  end

  test 'should post create en' do
    locale = :en
    cookies[:locale] = locale.to_s
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_differences([['User.count', 1],
                        ['GroupMembership.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      post :create,
           params: {user: attributes_for(:user)}
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'email')
    end
    assert_equal locale, User.last.language.to_sym
    sign_out :user
    User.last.destroy
  end

  test "guest should not post create when passwords don't match" do
    user_params = attributes_for(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_differences([['User.count', 0],
                        ['ActionMailer::Base.deliveries.count', 0]]) do
      post :create,
           params: {
             user: {
                 email: user_params[:email],
                 password: user_params[:password],
                 password_confirmation: 'random gibberish'
             }
           }
    end

    assert_response 200
    assert_analytics_collected('registrations', 'create', 'failed')
  end

  ####################################
  # As User
  ####################################
  test 'user should delete destroy' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user

    assert_difference('User.count', -1) do
      delete :destroy,
             params: {
               user: {
                   repeat_name: user.shortname.shortname,
                   current_password: 'password'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with placement' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    sign_in user

    assert_differences([['User.count', -1], ['Placement.count', -1], ['Place.count', 0]]) do
      delete :destroy,
             params: {
               user: {
                   repeat_name: user.shortname.shortname,
                   current_password: 'password'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with content' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create :motion, publisher: user, creator: user.profile, parent: freetown.edge
    create :question, publisher: user, creator: user.profile, parent: freetown.edge
    create :argument, parent: Motion.last.edge, publisher: user, creator: user.profile

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete :destroy,
             params: {
               user: {
                 repeat_name: user.shortname.shortname,
                 current_password: 'password'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with content published by page' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create :motion, publisher: user, creator: page.profile, parent: freetown.edge
    create :question, publisher: user, creator: page.profile, parent: freetown.edge
    create :argument, publisher: user, creator: page.profile, parent: Motion.last.edge

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete :destroy,
             params: {
               user: {
                 repeat_name: user.shortname.shortname,
                 current_password: 'password'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test 'owner should not delete destroy' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in owner

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      delete :destroy,
             params: {
               user: {
                   repeat_name: owner.url,
                   current_password: owner.password
               }
             }
    end
    assert_analytics_not_collected
  end
end
