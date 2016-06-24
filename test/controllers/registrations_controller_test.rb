require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  include TestHelper
  include Devise::TestHelpers

  define_freetown
  let(:user) { create(:user) }
  let(:place) { create(:place) }
  let(:page) { create(:page) }

  ####################################
  # As Guest
  ####################################

  test 'should post create' do
    I18n.available_locales.each do |locale|
      cookies[:locale] = locale.to_s
      @request.env['devise.mapping'] = Devise.mappings[:user]

      assert_differences([['User.count', 1],
                          ['Membership.count', 1],
                          ['Sidekiq::Worker.jobs.count', 1]]) do
        post :create,
             user: attributes_for(:user)
        assert_redirected_to setup_users_path
      end
      assert_equal locale, User.last.language.to_sym
      sign_out :user
      User.last.destroy
    end
  end

  test "should not post create when passwords don't match" do
    user_params = attributes_for(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_differences([['User.count', 0],
                        ['ActionMailer::Base.deliveries.count', 0]]) do
      post :create,
           user: {
               email: user_params[:email],
               password: user_params[:password],
               password_confirmation: 'random gibberish'
           }
    end

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  test 'user should delete destroy' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user

    assert_difference('User.count', -1) do
      delete :destroy,
             user: {
                 repeat_name: user.shortname.shortname,
                 current_password: 'password'
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with placement' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    sign_in user

    assert_differences([['User.count', -1], ['Placement.count', -1], ['Place.count', 0]]) do
      delete :destroy,
             user: {
                 repeat_name: user.shortname.shortname,
                 current_password: 'password'
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with content' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create :motion, publisher: user, creator: user.profile, parent: freetown.edge
    create :question, publisher: user, creator: user.profile, parent: freetown.edge
    create :argument, parent: Motion.last.edge, publisher: user, creator: user.profile

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete :destroy,
             user: {
               repeat_name: user.shortname.shortname,
               current_password: 'password'
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with content published by page' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create :motion, publisher: user, creator: page.profile, parent: freetown.edge
    create :question, publisher: user, creator: page.profile, parent: freetown.edge
    create :argument, publisher: user, creator: page.profile, parent: motion.edge

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete :destroy,
             user: {
               repeat_name: user.shortname.shortname,
               current_password: 'password'
             }
    end

    assert_redirected_to root_path
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
             user: {
                 repeat_name: owner.url,
                 current_password: owner.password
             }
    end
  end
end
