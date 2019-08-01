# frozen_string_literal: true

require 'test_helper'

class RegistrationsTest < ActionDispatch::IntegrationTest
  include TestHelper

  define_freetown
  let(:user) { create(:user) }
  let(:user_no_shortname) { create(:user, :no_shortname, first_name: nil, last_name: nil) }
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(id: 'other_id') }
  let(:place) { create(:place) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) { create(:argument, parent: motion) }
  let(:motion2) { create(:motion, parent: freetown) }
  let(:motion3) { create(:motion, parent: freetown) }
  let(:guest_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: guest_user.profile,
           publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote,
           parent: motion2.default_vote_event,
           creator: guest_user.profile,
           publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:other_guest_vote3) do
    create(:vote,
           parent: motion3.default_vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:argument_guest_vote) do
    create(:vote, parent: argument, creator: guest_user.profile, publisher: guest_user)
  end

  ####################################
  # As Guest
  ####################################
  test 'should get new' do
    get new_user_registration_path
    assert_response 200
  end

  test 'should not post create existing' do
    user
    assert_difference('User.count' => 0,
                      'Favorite.count' => 0,
                      'Notification.confirmation_reminder.count' => 0) do
      post user_registration_path,
           params: {
             user: {
               email: user.email
             }
           }, headers: argu_headers(accept: :json)
    end
    assert_response 422
  end

  test 'should not post create existing new fe' do
    sign_in :service
    user
    assert_difference('User.count' => 0,
                      'Favorite.count' => 0,
                      'Notification.confirmation_reminder.count' => 0) do
      post "/#{argu.url}#{user_registration_path}",
           params: {
             user: {
               email: user.email
             }
           }, headers: argu_headers(accept: :nq)
    end
    assert_response 422
  end

  test 'should block spammer' do
    r = '/freetown/con/846/c/new?comment%5Bbody%5D=online+casino&confirm=true'
    attrs = attributes_for(:user)
    attrs[:r] = r

    assert_difference('User.count' => 0,
                      'Favorite.count' => 0,
                      worker_count_string('RedisResourceWorker') => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      post user_registration_path,
           params: {user: attrs, accept_terms: true, r: r}
      assert_response 200
    end
    assert_includes(
      response.body,
      'It seems like you&#39;re trying to post a comment containing advertising or illegal content'
    )
  end

  test 'should not block valid content' do
    r = '/freetown/con/846/c/new?comment%5Bbody%5D=valid+comment&confirm=true'
    attrs = attributes_for(:user)
    attrs[:r] = r

    assert_difference('User.count' => 1,
                      'Favorite.count' => 0,
                      worker_count_string('RedisResourceWorker') => 1,
                      worker_count_string('SendEmailWorker') => 1) do
      post user_registration_path,
           params: {user: attrs, accept_terms: true, r: r}
      assert_response 302
    end
  end

  test 'should post create en' do
    sign_in guest_user
    locale = :en
    put language_users_path(locale: locale)
    create_email_mock('confirmation', 'test@example.com', confirmationToken: /.+/)

    Sidekiq::Testing.inline! do
      assert_difference('User.count' => 1,
                        'Favorite.count' => 0,
                        'Notification.confirmation_reminder.count' => 0) do
        post user_registration_path,
             params: {
               user: {
                 email: 'test@example.com',
                 password: 'password',
                 password_confirmation: 'password'
               },
               accept_terms: true
             }
        assert_redirected_to setup_users_path
      end
    end
    assert_equal locale, User.last.language.to_sym
    assert_not_nil User.last.current_sign_in_ip
    assert_not_nil User.last.current_sign_in_at
    assert_not_nil User.last.last_sign_in_ip
    assert_not_nil User.last.last_sign_in_at
    assert User.last.accepted_terms?

    delete destroy_user_session_path

    assert_difference('EmailAddress.where(confirmed_at: nil).count' => -1) do
      get user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end
    assert_redirected_to new_user_session_path
    assert_email_sent(skip_sidekiq: true)
  end

  test 'should post create nl' do
    locale = :nl
    put language_users_path(locale: locale)
    attrs = attributes_for(:user)
    create_email_mock('confirmation', attrs[:email], confirmationToken: /.+/)

    assert_difference('User.count' => 1,
                      'Favorite.count' => 0,
                      worker_count_string('RedisResourceWorker') => 1,
                      worker_count_string('SendEmailWorker') => 1) do
      post user_registration_path,
           params: {user: attrs}
      assert_redirected_to setup_users_path
    end
    assert_equal locale, User.last.language.to_sym
  end

  test 'should post create after visiting freetown' do
    locale = :nl
    put language_users_path(locale: locale)
    attrs = attributes_for(:user)
    create_email_mock('confirmation', attrs[:email], confirmationToken: /.+/)
    get freetown.iri.path

    assert_difference('User.count' => 1,
                      'Favorite.count' => 1,
                      worker_count_string('RedisResourceWorker') => 1,
                      worker_count_string('SendEmailWorker') => 1) do
      post user_registration_path,
           params: {user: attrs}
      assert_redirected_to setup_users_path
    end
    assert_equal locale, User.last.language.to_sym
    assert_email_sent
  end

  test 'should post create without password' do
    assert_difference('User.count' => 1,
                      'EmailAddress.where(confirmed_at: nil).count' => 1) do
      post user_registration_path,
           params: {
             user: {
               email: 'test@example.com'
             }
           },
           headers: argu_headers(accept: :json)
      assert_response 201
    end
    assert_not User.last.accepted_terms?
    assert_equal parsed_body['data']['attributes']['email'], 'test@example.com'
    assert_equal parsed_body['data']['relationships']['emailAddresses']['data'].count, 1
  end

  test 'should post create without password and transfer and persist guest votes' do
    other_guest_vote
    get root_path
    guest_vote
    guest_vote2
    other_guest_vote3
    argument_guest_vote
    create_email_mock(
      'confirm_votes',
      'test@example.com',
      confirmationToken: /.+/,
      motions: [
        {display_name: motion.display_name, option: 'pro', url: argu_url(motion.iri.path)},
        {display_name: motion2.display_name, option: 'pro', url: argu_url(motion2.iri.path)}
      ]
    )

    Sidekiq::Testing.inline! do
      assert_difference('User.count' => 1,
                        'Favorite.count' => 1,
                        'Vote.count' => 3,
                        'Argu::Redis.keys("temporary*").count' => -3,
                        'EmailAddress.where(confirmed_at: nil).count' => 1) do
        post user_registration_path,
             params: {
               user: {
                 email: 'test@example.com'
               }
             },
             headers: argu_headers(accept: :json)
        assert_response 201
      end
    end

    delete destroy_user_session_path

    assert_difference('EmailAddress.where(confirmed_at: nil).count' => -1,
                      'Edge.where(confirmed: true).count' => 3) do
      get user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end
    assert_response 200
    assert User.last.encrypted_password == ''

    put users_confirm_path,
        params: {
          user: {
            confirmation_token: User.last.confirmation_token,
            password: 'password',
            password_confirmation: 'password'
          }
        }
    assert_redirected_to setup_users_path
    assert_not User.last.encrypted_password == ''
    assert_email_sent(skip_sidekiq: true)
  end

  test 'should post create transfer guest votes' do
    get root_path
    guest_vote
    guest_vote2
    other_guest_vote
    other_guest_vote3
    argument_guest_vote
    attrs = attributes_for(:user)
    create_email_mock(
      'confirm_votes',
      attrs[:email],
      confirmationToken: /.+/,
      motions: [
        {display_name: motion.display_name, option: 'pro', url: argu_url(motion.iri.path)},
        {display_name: motion2.display_name, option: 'pro', url: argu_url(motion2.iri.path)}
      ]
    )

    Sidekiq::Testing.inline! do
      assert_difference('User.count' => 1,
                        'Vote.count' => 3,
                        'Argu::Redis.keys("temporary*").count' => -3,
                        'Favorite.count' => 1,
                        'Notification.confirmation_reminder.count' => 1) do
        post "/#{argu.url}#{user_registration_path}",
             params: {user: attrs}
      end
    end
    assert_redirected_to setup_users_path
    assert_email_sent(skip_sidekiq: true)

    create_email_mock('confirmation_reminder', attrs[:email], token: /.+/)

    Sidekiq::Testing.inline! do
      # rubocop:disable Rails/SkipsModelValidations
      Notification
        .where('notification_type != ?', Notification.notification_types[:confirmation_reminder])
        .update_all(read_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
      travel 2.days do
        DirectNotificationsSchedulerWorker.new.perform
      end
    end

    assert_email_sent(skip_sidekiq: true)
  end

  test "guest should not post create when passwords don't match" do
    user_params = attributes_for(:user)

    assert_difference('User.count' => 0,
                      worker_count_string('RedisResourceWorker') => 0,
                      worker_count_string('SendEmailWorker') => 0) do
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
  end

  ####################################
  # As User
  ####################################
  test 'user should delete destroy' do
    sign_in user

    assert_difference('User.count' => -1) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
  end

  test 'user should not delete destroy without confirmation' do
    sign_in user

    assert_difference('User.count' => 0) do
      delete user_registration_path,
             params: {
               user: {}
             }
    end
  end

  test 'user should delete destroy with group_membership' do
    sign_in user
    group = create(:group, parent: argu)
    create(:group_membership, parent: group, member: user.profile)

    assert_difference('User.count' => -1, 'GroupMembership.active.count' => -2, 'GroupMembership.count' => 0) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_not Profile.community.is_group_member?(group.id)

    assert_redirected_to root_path
  end

  test 'user without name and shortname should delete destroy' do
    sign_in user_no_shortname

    assert_difference('User.count' => -1) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with placement, uploaded_photo and expired group_membership' do
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save
    photo = motion.build_default_cover_photo(
      creator: user.profile,
      publisher: user,
      content: Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'profile_photo.png'))
    )
    photo.save!
    create(
      :group_membership,
      parent: create(:group, parent: argu),
      member: user.profile,
      start_date: 2.minutes.ago,
      end_date: 1.minute.ago
    )

    sign_in user

    assert_difference('User.count' => -1, 'Placement.count' => -1, 'Place.count' => 0,
                      'MediaObject.count' => -1, 'MediaObject.where(publisher_id: 0, creator_id: 0).count' => 1) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with content' do
    motion = create :motion, publisher: user, creator: user.profile, parent: freetown
    create :vote, publisher: user, creator: user.profile, parent: motion.default_vote_event
    create :question, publisher: user, creator: user.profile, parent: freetown
    create :argument, parent: Motion.last, publisher: user, creator: user.profile

    sign_in user

    assert_difference('User.count' => -1, 'Edge.count' => -user.votes.count) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
  end

  test 'user should delete destroy with content published by page' do
    create :motion, publisher: user, creator: argu.profile, parent: freetown
    create :question, publisher: user, creator: argu.profile, parent: freetown
    create :argument, publisher: user, creator: argu.profile, parent: Motion.last

    sign_in user

    assert_difference('User.count' => -1) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_redirected_to root_path
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should not delete destroy' do
    sign_in administrator

    assert_difference('User.count' => 0) do
      delete user_registration_path,
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end
    assert_not_authorized
  end
end
