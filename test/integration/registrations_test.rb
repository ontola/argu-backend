# frozen_string_literal: true
require 'test_helper'
require 'capybara/email'

class RegistrationsTest < ActionDispatch::IntegrationTest
  include TestHelper, Capybara::Email::DSL

  setup do
    analytics_collect
  end

  define_freetown
  let(:user) { create(:user) }
  let(:guest_user) { GuestUser.new(session: session) }
  let(:other_guest_user) { GuestUser.new(id: 'other_id') }
  let(:place) { create(:place) }
  let(:argu) { create(:page) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:motion2) { create(:motion, parent: freetown.edge) }
  let(:motion3) { create(:motion, parent: freetown.edge) }
  let(:guest_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: guest_user.profile,
           publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote,
           parent: motion2.default_vote_event.edge,
           creator: guest_user.profile,
           publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:other_guest_vote3) do
    create(:vote,
           parent: motion3.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end

  ####################################
  # As Guest
  ####################################

  test 'should post create en' do
    clear_emails
    locale = :en
    cookies[:locale] = locale.to_s

    assert_differences([['User.count', 1],
                        ['Favorite.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      post user_registration_path,
           params: {
             user: {
               email: 'test@example.com',
               password: 'password',
               password_confirmation: 'password'
             }
           }
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'email')
    end
    assert_equal locale, User.last.language.to_sym
    assert_not_nil User.last.current_sign_in_ip
    assert_not_nil User.last.current_sign_in_at
    assert_not_nil User.last.last_sign_in_ip
    assert_not_nil User.last.last_sign_in_at

    delete destroy_user_session_path

    assert_difference('Email.where(confirmed_at: nil).count', -1) do
      get user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end
    assert_redirected_to new_user_session_path

    sign_in User.last
    get root_path
    assert_redirected_to setup_users_path
  end

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

  test 'should post create without password and transfer and persist guest votes' do
    other_guest_vote
    get root_path
    guest_vote
    guest_vote2
    other_guest_vote3

    locale = :en
    cookies[:locale] = locale.to_s
    clear_emails

    Sidekiq::Testing.inline! do
      assert_differences([['User.count', 1],
                          ['Email.where(confirmed_at: nil).count', 1]]) do
        post user_registration_path,
             params: {
               format: :json,
               user: {
                 email: 'test@example.com'
               }
             }
        assert_response 201
        assert_analytics_collected('registrations', 'create', 'email')
      end
    end
    assert_not_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion.default_vote_event.edge.path}")
    assert_not_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion2.default_vote_event.edge.path}")

    get forum_path(freetown), params: {format: :json_api}
    assert_response 200
    get forum_path(freetown)
    assert_redirected_to setup_users_path

    delete destroy_user_session_path

    assert_difference('Email.where(confirmed_at: nil).count', 0) do
      get user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end
    assert_response 200
    assert User.last.encrypted_password == ''

    assert_difference('Email.where(confirmed_at: nil).count', -1) do
      put users_confirm_path,
          params: {
            user: {
              confirmation_token: User.last.confirmation_token,
              password: 'password',
              password_confirmation: 'password'
            }
          }
      assert_redirected_to root_path
    end
    assert_not User.last.encrypted_password == ''

    sign_in User.last
    get root_path
    assert_redirected_to setup_users_path
  end

  test 'should post create transfer guest votes' do
    get root_path
    guest_vote
    guest_vote2
    other_guest_vote
    other_guest_vote3

    Sidekiq::Testing.inline! do
      assert_differences([['User.count', 1],
                          ['Vote.count', 0],
                          ['Favorite.count', 1]]) do
        post user_registration_path,
             params: {user: attributes_for(:user)}
      end
    end
    assert_redirected_to setup_users_path
    assert_not_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion.default_vote_event.edge.path}")
    assert_not_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion2.default_vote_event.edge.path}")
    assert_analytics_collected('registrations', 'create', 'email')
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
                        ['MediaObject.count', -1], ['MediaObject.where(publisher_id: 0, creator_id: 0).count', 1]]) do
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
    create :motion, publisher: user, creator: argu.profile, parent: freetown.edge
    create :question, publisher: user, creator: argu.profile, parent: freetown.edge
    create :argument, publisher: user, creator: argu.profile, parent: Motion.last.edge

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
  # As Admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  test 'super_admin should not delete destroy' do
    sign_in super_admin

    assert_differences([['User.count', 0]]) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end
    assert_not_authorized
    assert_analytics_not_collected
  end
end
