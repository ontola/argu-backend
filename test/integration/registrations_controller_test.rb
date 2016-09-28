# frozen_string_literal: true
require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    analytics_collect
  end

  define_freetown
  let(:user) { create(:user) }
  let(:place) { create(:place) }
  let(:page) { create(:page) }
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################

  test 'should post create nl' do
    locale = :nl
    cookies[:locale] = locale.to_s

    assert_differences([['User.count', 1],
                        ['Favorite.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      post user_registration_path,
           params: {user: attributes_for(:user)}
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'email')
    end
    assert_equal locale, User.last.language.to_sym
  end

  test 'should post create en' do
    locale = :en
    cookies[:locale] = locale.to_s

    assert_differences([['User.count', 1],
                        ['Favorite.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      post user_registration_path,
           params: {user: attributes_for(:user)}
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'email')
    end
    assert_equal locale, User.last.language.to_sym
  end

  test "guest should not post create when passwords don't match" do
    user_params = attributes_for(:user)

    assert_differences([['User.count', 0],
                        ['ActionMailer::Base.deliveries.count', 0]]) do
      post user_registration_path,
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
    sign_in user

    assert_difference('User.count', -1) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with placement and uploaded_photo' do
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save
    photo = motion.build_default_cover_photo(creator: user.profile, publisher: user)
    photo.save

    sign_in user

    assert_differences([['User.count', -1], ['Placement.count', -1], ['Place.count', 0],
                        ['Photo.count', -1], ['Photo.where(publisher_id: 0, creator_id: 0).count', 1]]) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with content' do
    create :motion, publisher: user, creator: user.profile, parent: freetown.edge
    create :question, publisher: user, creator: user.profile, parent: freetown.edge
    create :argument, parent: Motion.last.edge, publisher: user, creator: user.profile

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
    assert_analytics_collected('registrations', 'destroy', user.id)
  end

  test 'user should delete destroy with content published by page' do
    create :motion, publisher: user, creator: page.profile, parent: freetown.edge
    create :question, publisher: user, creator: page.profile, parent: freetown.edge
    create :argument, publisher: user, creator: page.profile, parent: Motion.last.edge

    sign_in user

    assert_differences([['User.count', -1]]) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
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
    sign_in owner

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end
    assert_analytics_not_collected
  end
end
