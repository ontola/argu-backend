# frozen_string_literal: true

require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo

  let(:user) { create(:user) }
  let(:second_email) { create(:email, user: user, email: 'second@argu.co', confirmed_at: DateTime.current) }
  let(:unconfirmed_email) { create(:email, user: user, email: 'unconfirmed@argu.co') }
  let(:super_admin) { create_super_admin(freetown) }
  let(:user_public) { create(:user, profile: create(:profile)) }
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }
  let(:dutch_forum) { create_forum(public_grant: 'member', locale: 'nl-NL') }

  ####################################
  # Show as Guest
  ####################################
  test 'guest should get show by id' do
    get user_path(user_public.id)

    assert_redirected_to user_public
  end

  test 'guest should not get show non public' do
    get user_path(user_non_public)

    assert_response 403
  end

  test 'guest should get show without feed' do
    get user_path(user_hidden_votes)

    assert_response 200

    assert_select '.activity-feed', 0
  end

  test 'guest should get show public' do
    get user_path(user_public)

    assert_response 200
  end

  ####################################
  # Show as User
  ####################################
  test 'user should get show by id' do
    sign_in user

    get user_path(user_public.id)

    assert_redirected_to user_public
  end

  test 'user should get show non public' do
    sign_in user

    get user_path(user_non_public)

    assert_response 200
  end

  test 'user should get show without feed' do
    sign_in user

    get user_path(user_hidden_votes)

    assert_response 200

    assert_select '.activity-feed', 0
  end

  test 'user should get show public' do
    sign_in user

    get user_path(user_public)

    assert_response 200

    assert_select '.activity-feed'
  end

  test 'user should show votes own profile' do
    sign_in user_hidden_votes

    get user_path(user_hidden_votes)

    assert_response 200
  end

  ####################################
  # Sign out
  ####################################
  test 'user should sign out' do
    sign_in user

    get destroy_user_session_path
    assert_redirected_to '/'
  end

  test 'user should sign out with r' do
    sign_in user

    get destroy_user_session_path(r: forum_path(freetown))
    assert_redirected_to forum_path(freetown)
  end

  test 'user should sign out with invalid r' do
    sign_in user

    get destroy_user_session_path(r: 'https://evil_website.com')
    assert_redirected_to '/'
  end

  ####################################
  # Emails
  ####################################
  test 'user should add second email' do
    sign_in user
    assert_differences([['Email.count', 1],
                        ['Sidekiq::Worker.jobs.count', 0]]) do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1490174149635': {email: 'secondary@argu.co'}
              },
              current_password: user.password
            }
          }
    end
    user.reload
    assert_equal user.emails.count, 2
    assert_equal user.emails.last.email, 'secondary@argu.co'
    assert_not_equal user.primary_email_record.email, 'secondary@argu.co'

    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should switch primary email' do
    sign_in user
    second_email

    assert_not_equal user.primary_email_record.email, second_email.email

    assert_differences([['Email.count', 0],
                        ['Sidekiq::Worker.jobs.count', 0]]) do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1': {email: second_email.email, id: second_email.id}
              },
              primary_email: '[1]',
              current_password: user.password
            }
          }
    end
    user.reload
    assert_equal user.emails.where(primary: true).count, 1
    assert_not_equal user.emails.last.email, second_email.email
    assert_equal user.primary_email_record.email, second_email.email

    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should delete secondary email' do
    sign_in user
    second_email

    assert_differences([['Email.count', -1],
                        ['Sidekiq::Worker.jobs.count', 0]]) do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id, _destroy: 'false'},
                '1': {email: second_email.email, id: second_email.id, _destroy: '1'}
              },
              current_password: user.password
            }
          }
    end

    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should not delete primary email' do
    sign_in user
    second_email

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      assert_differences([['Email.count', 0],
                          ['Sidekiq::Worker.jobs.count', 0]]) do
        put user_path(user),
            params: {
              user: {
                emails_attributes: {
                  '0': {email: user.primary_email_record.email, id: user.primary_email_record.id, _destroy: '1'},
                  '1': {email: second_email.email, id: second_email.id, _destroy: '0'}
                },
                current_password: user.password
              }
            }
      end
    end
  end

  test 'user should change unconfirmed email' do
    sign_in user
    unconfirmed_email
    assert_differences([['Email.count', 0],
                        ['Sidekiq::Worker.jobs.count', 0]]) do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1': {email: 'changed@argu.co', id: unconfirmed_email.id}
              },
              current_password: user.password
            }
          }
    end
    unconfirmed_email.reload
    assert_equal unconfirmed_email.email, 'changed@argu.co'

    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should not change confirmed email' do
    sign_in user
    second_email
    assert_differences([['Email.count', 0],
                        ['Sidekiq::Worker.jobs.count', 0]]) do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1': {email: 'changed@argu.co', id: second_email.id}
              },
              current_password: user.password
            }
          }
    end
    second_email.reload
    assert_equal second_email.email, 'second@argu.co'
  end

  ##########################################
  # Wrong email after following email token
  ##########################################
  test 'guest should not get wrong_email' do
    get users_wrong_email_path(email: 'wrong@email.com')
  end

  test 'user should get wrong_email' do
    sign_in user
    get users_wrong_email_path(email: 'wrong@email.com')
  end

  test 'user with correct email should redirect to r on wrong_email' do
    sign_in user

    assert_no_difference('Email.count') do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '99999' => {email: user.email}
              },
              form: 'wrong_email',
              r: argu_url('/tokens/email/xxx')
            }
          }
    end

    assert_redirected_to argu_url('/tokens/email/xxx')
  end

  test 'user with other email should redirect to r on wrong_email' do
    sign_in user

    assert_difference('Email.count') do
      put user_path(user),
          params: {
            user: {
              emails_attributes: {
                '99999' => {email: 'new@email.com'}
              },
              form: 'wrong_email',
              r: argu_url('/tokens/email/xxx')
            }
          }
    end

    assert_redirected_to argu_url('/tokens/email/xxx')
  end

  test 'user should not add email of other account on wrong_email' do
    sign_in user_public
    user

    assert_no_difference('Email.count') do
      put user_path(user_public),
          params: {
            user: {
              emails_attributes: {
                '99999' => {email: user.email}
              },
              form: 'wrong_email',
              r: argu_url('/tokens/email/xxx')
            }
          }
    end

    assert_select '.account-exists', "An account for #{user.email} already exists. "\
                                     'Log out and log in with this other account to accept the invitation.'
  end

  ####################################
  # Language
  ####################################
  test 'guest should get language cookie' do
    get forum_path(freetown)
    assert_equal 'en', cookies['locale']
    assert_nil flash[:error]
  end

  test 'guest should get language cookie when visiting dutch forum' do
    get forum_path(dutch_forum)
    assert_equal 'nl', cookies['locale']
    assert_nil flash[:error]
  end

  test 'guest should put language' do
    get forum_path(freetown)
    assert_equal 'en', cookies['locale']
    put language_users_path(:nl)
    assert_equal 'nl', cookies['locale']
    assert_nil flash[:error]
  end

  test 'user should put language' do
    sign_in user
    assert_equal 'en', user.language
    put language_users_path(:nl)
    assert_equal 'nl', user.reload.language
    assert_nil flash[:error]
  end

  test 'user should not put non-existing language' do
    sign_in user
    assert_equal 'en', user.language
    put language_users_path(:fake_language)
    assert_equal 'en', user.reload.language
    assert flash[:error].present?
  end

  ####################################
  # Settings and Update
  ####################################
  test 'user should show settings and all tabs' do
    sign_in user

    get settings_user_path
    assert_user_settings_shown

    %i(general profile authentication notifications privacy advanced).each do |tab|
      get settings_user_path(tab: tab)
      assert_user_settings_shown tab
    end
  end

  test 'user should update profile_photo and cover_photo' do
    nominatim_postal_code_valid
    sign_in user

    put user_path(user),
        params: {
          user: {
            first_name: 'name',
            profile_attributes: {
              id: user.profile.id,
              default_profile_photo_attributes: {
                id: user.profile.default_profile_photo.id,
                content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
              },
              default_cover_photo_attributes: {
                content: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg')
              }
            }
          }
        }
    assert_equal 'name', user.reload.first_name
    assert_equal 2, user.profile.media_objects.reload.count
    assert_equal('profile_photo.png', user.profile.default_profile_photo.content_identifier)
    assert_equal('cover_photo.jpg', user.profile.default_cover_photo.content_identifier)

    assert_redirected_to settings_user_path(tab: :general)
  end

  let(:place) { create(:place) }
  test 'user should create place and placement on update with postal_code and country code' do
    nominatim_postal_code_valid
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                postal_code: '3583GP',
                country_code: 'NL'
              }
            }
          }
    end
    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should create place and placement on update with only country code' do
    nominatim_country_code_only
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                postal_code: '',
                country_code: 'NL'
              }
            }
          }
    end
    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should not create place and placement on update with only postal code' do
    sign_in user

    assert_differences [['Place.count', 0],
                        ['Placement.count', 0]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                postal_code: '3583GP',
                country_code: ''
              }
            }
          }
    end
    assert_response 200
  end

  test 'user should not create place and placement on update with wrong postal code' do
    nominatim_postal_code_wrong
    sign_in user

    assert_differences [['Place.count', 0],
                        ['Placement.count', 0]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                postal_code: 'wrong_postal_code',
                country_code: 'NL'
              }
            }
          }
    end
    assert_response 200
  end

  test 'user should not create place but should create placement on update with cached postal code and country code' do
    sign_in user
    place

    assert_differences [['Place.count', 0],
                        ['Placement.count', 1]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                postal_code: '3583GP',
                country_code: 'NL'
              }
            }
          }
    end
    assert_redirected_to settings_user_path(tab: :general)
  end

  test 'user should destroy placement on update with blank postal code and country code' do
    sign_in user
    place
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    assert_differences [['Place.count', 0],
                        ['Placement.count', -1]] do
      put user_path(user),
          params: {
            user: {
              first_name: 'name',
              home_placement_attributes: {
                id: placement.id,
                postal_code: '',
                country_code: ''
              }
            }
          }
    end
    assert_redirected_to settings_user_path(tab: :general)
  end

  private

  # Asserts that the user settings are shown on a specific tab
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_user_settings_shown(tab = :general)
    assert_response 200
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    tab.to_s.capitalize
  end
end
