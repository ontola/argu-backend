# frozen_string_literal: true

require 'test_helper'

class RegistrationsTest < ActionDispatch::IntegrationTest
  include TestHelper

  define_freetown
  define_cairo
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(session_id: 'other_id') }
  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) { create(:pro_argument, parent: motion) }
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
  test 'should not post create existing json' do
    sign_in guest_user
    user
    assert_difference('User.count' => 0,
                      'GroupMembership.count' => 0,
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

  test 'should not post create existing nq' do
    sign_in :service
    user
    assert_difference('User.count' => 0,
                      'GroupMembership.count' => 0,
                      'Notification.confirmation_reminder.count' => 0) do
      post user_registration_path,
           params: {
             user: {
               email: user.email
             }
           }, headers: argu_headers(accept: :nq)
    end
    assert_response 422
  end

  test 'should post create en' do
    sign_in guest_user
    Sidekiq::Testing.inline! do
      create_user_with_locale(:en)
    end

    assert_difference('EmailAddress.where(confirmed_at: nil).count' => -1) do
      put user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end
    assert_response :success
  end

  test 'should post create with redirect_url' do
    sign_in guest_user
    create_user(redirect_url: motion.iri.path)
  end

  test 'should post create nl' do
    sign_in guest_user
    assert_difference(worker_count_string('RedisResourceWorker') => 1) do
      create_user_with_locale(:nl)
    end
  end

  test 'should post create without password' do
    create_email_mock('set_password', 'test@example.com', token_url: /.+/)
    sign_in guest_user
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
    assert_equal User.last.email, 'test@example.com'
    assert_equal parsed_body['data']['attributes']['email'], 'test@example.com'
    assert_equal parsed_body['data']['relationships']['email_addresses']['data'].count, 1
    assert_email_sent
  end

  test 'should post create without password and transfer and persist guest votes' do
    sign_in guest_user
    other_guest_vote
    guest_vote
    guest_vote2
    other_guest_vote3
    argument_guest_vote
    create_email_mock(
      'confirm_votes',
      'test@example.com',
      token_url: /.+/,
      motions: [
        {display_name: motion.display_name, option: 'Agree', url: motion.iri},
        {display_name: motion2.display_name, option: 'Agree', url: motion2.iri}
      ]
    )

    Sidekiq::Testing.inline! do
      assert_difference('User.count' => 1,
                        'Vote.published.count' => 3,
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
    assert_email_sent(skip_sidekiq: true)

    delete sign_out_path

    create_email_mock('password_changed', 'test@example.com')
    assert_difference('EmailAddress.where(confirmed_at: nil).count' => -1,
                      'Edge.where(confirmed: true).count' => 3) do
      put user_password_path,
          params: {
            user: {
              reset_password_token: User.last.send(:set_reset_password_token),
              password: 'password',
              password_confirmation: 'password'
            }
          }
    end
    assert_response :success
    assert_equal response.header['Location'], '/argu/u/session/new'
    assert_not User.last.encrypted_password == ''
    assert_email_sent
  end

  test 'should post create transfer guest votes' do
    sign_in guest_user
    guest_vote
    guest_vote2
    other_guest_vote
    other_guest_vote3
    argument_guest_vote
    attrs = attributes_for(:user)
    create_email_mock(
      'confirm_votes',
      attrs[:email],
      token_url: /.+/,
      motions: [
        {display_name: motion.display_name, option: 'Agree', url: motion.iri},
        {display_name: motion2.display_name, option: 'Agree', url: motion2.iri}
      ]
    )

    Sidekiq::Testing.inline! do
      assert_difference('User.count' => 1,
                        'Vote.published.count' => 3,
                        'Argu::Redis.keys("temporary*").count' => -3,
                        'Notification.confirmation_reminder.count' => 1) do
        post user_registration_path,
             params: {user: attrs}
      end
    end
    assert_response :success
    assert_equal response.header['Location'], edit_iri(User.last, root: argu)
    assert_email_sent(skip_sidekiq: true)

    create_email_mock('confirmation_reminder', attrs[:email], token_url: /.+/)

    Sidekiq::Testing.inline! do
      # rubocop:disable Rails/SkipsModelValidations
      Notification
        .where.not(notification_type: Notification.notification_types[:confirmation_reminder])
        .update_all(read_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
      travel 2.days do
        DirectNotificationsSchedulerWorker.new.perform
      end
    end

    assert_email_sent(skip_sidekiq: true)
  end

  test "guest should not post create when passwords don't match" do
    sign_in guest_user
    user_params = attributes_for(:user)

    assert_difference('User.count' => 0,
                      'GroupMembership.count' => 0,
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

    assert_response :unprocessable_entity
  end

  ####################################
  # As User
  ####################################
  test 'user should delete destroy' do
    sign_in user

    assert_difference('User.count' => -1) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_response :success
    assert_equal decoded_token_from_response['scopes'], %w[guest]
  end

  test 'user should not delete destroy without confirmation' do
    sign_in user

    assert_difference('User.count' => 0) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: ''
               }
             }
      assert_response :unprocessable_entity
    end
  end

  test 'user should not delete destroy with wrong confirmation' do
    sign_in user

    assert_difference('User.count' => 0) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'wrong'
               }
             }
      assert_response :unprocessable_entity
    end
  end

  test 'user should delete destroy with group_membership' do
    sign_in user
    group = create(:group, parent: argu)
    create(:group_membership, parent: group, member: user.profile)

    assert_difference('User.count' => -1, 'GroupMembership.active.count' => -2, 'GroupMembership.count' => 0) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_not Profile.community.is_group_member?(group.id)

    assert_response :success
  end

  test 'user should delete destroy with placement, uploaded_photo and expired group_membership' do
    photo = motion.build_default_cover_photo(
      creator: user.profile,
      publisher: user,
      content: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/profile_photo.png'))
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

    assert_difference('User.count' => -1,
                      'MediaObject.count' => -1,
                      'MediaObject.where(publisher_id: 0, creator_id: 0).count' => 1) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_response :success
  end

  test 'user should delete destroy and expropriate content' do
    create_content_for(user)

    sign_in user

    assert_difference(
      'User.count' => -1,
      'Edge.count' => -user.votes.count,
      'Edge.where(creator_id: Profile::COMMUNITY_ID).count' => 6
    ) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_response :success
  end

  test 'staff should delete destroy and destroy content' do
    create_content_for(user)

    sign_in staff

    assert_difference(
      'User.count' => -1,
      'Edge.count' => - user.votes.count - 6
    ) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove',
                 destroy_strategy: :remove_on_destroy
               }
             }
      assert_response :success
    end
  end

  test 'user should delete destroy with content published by page' do
    create :motion, publisher: argu.publisher, creator: argu.profile, parent: freetown
    create :question, publisher: argu.publisher, creator: argu.profile, parent: freetown
    create :pro_argument, publisher: argu.publisher, creator: argu.profile, parent: Motion.last

    sign_in user

    assert_difference(
      'User.count' => -1,
      'Edge.count' => 0,
      'Edge.where(creator_id: Profile::COMMUNITY_ID).count' => 0
    ) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_response :success
  end

  test 'user should not delete destroy other user' do
    sign_in user
    other_user

    assert_difference('User.count' => 0) do
      delete resource_iri(other_user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_not_authorized
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should not delete destroy' do
    sign_in administrator

    assert_difference('User.count' => 0) do
      delete resource_iri(administrator, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end
    assert_not_authorized
  end

  test 'administrator should not delete destroy other user' do
    sign_in administrator
    other_user

    assert_difference('User.count' => 0) do
      delete resource_iri(other_user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end

    assert_not_authorized
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should delete destroy other user' do
    sign_in staff
    user

    assert_difference('User.count' => -1) do
      delete resource_iri(user, root: argu),
             params: {
               user: {
                 confirmation_string: 'remove'
               }
             }
    end
    assert_response :success
  end

  private

  def create_content_for(user) # rubocop:disable Metrics/MethodLength
    motion = create(
      :motion,
      publisher: user,
      creator: user.profile,
      parent: freetown,
      placement_attributes: {lat: 1.0, lon: 1.0}
    )
    create(:vote, publisher: user, creator: user.profile, parent: motion.default_vote_event)
    create(:question, publisher: user, creator: user.profile, parent: freetown)
    create(:pro_argument, parent: Motion.last, publisher: user, creator: user.profile)
    create(:motion, publisher: user, creator: user.profile, parent: cairo)
  end

  def create_user(redirect_url: nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    yield if block_given?

    create_email_mock('confirmation', 'test@example.com', token_url: /.+/)
    assert_difference(
      'User.count' => 1,
      'GroupMembership.count' => 1,
      'Notification.confirmation_reminder.count' => 0
    ) do
      post user_registration_path,
           params: {
             user: {
               accept_terms: true,
               email: 'test@example.com',
               password: 'password',
               password_confirmation: 'password',
               redirect_url: redirect_url
             }
           }
      assert_response :success
      assert_equal response.header['Location'], redirect_url || edit_iri(User.last, root: argu)
    end

    assert_equal 'test@example.com', User.last.email
    assert_not User.last.confirmed?
    assert_not_nil User.last.current_sign_in_ip
    assert_not_nil User.last.current_sign_in_at
    assert_not_nil User.last.last_sign_in_ip
    assert_not_nil User.last.last_sign_in_at
    assert User.last.accepted_terms?
    assert_email_sent
  end

  def create_user_with_locale(locale, &block)
    put iri_from_template(:languages_iri, root: argu), params: {user: {language: locale}}
    create_user(&block)
    assert_equal locale, User.last.language.to_sym
  end

  def sign_out_path
    "#{argu.iri}/u/sign_out"
  end

  def user_confirmation_path(params = nil)
    ["/#{argu.url}/u/confirmation", params&.to_param].compact.join('?')
  end

  def user_password_path
    "#{argu.iri}/u/password"
  end

  def user_registration_path
    "#{argu.iri}/u/registration"
  end
end
