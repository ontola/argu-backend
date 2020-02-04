# frozen_string_literal: true

require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  include JWTHelper

  define_freetown
  define_cairo

  let(:user) { create(:user) }
  let(:second_email) { create(:email_address, user: user, email: 'second@argu.co', confirmed_at: Time.current) }
  let(:unconfirmed_email) { create(:email_address, user: user, email: 'unconfirmed@argu.co') }
  let(:administrator) { create_administrator(freetown) }
  let(:user_public) { create(:user, profile: create(:profile)) }
  let(:user_hidden_last_name) { create(:user, hide_last_name: true) }
  let(:user_no_shortname) do
    u = create(:user, profile: create(:profile))
    u.shortname.destroy
    u
  end
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }
  let(:dutch_forum) { create_forum(public_grant: 'participator', locale: 'nl-NL') }

  ####################################
  # Show as Guest
  ####################################
  test 'guest should get show by id' do
    get user_path(user_public.id)

    ActsAsTenant.current_tenant = argu
    assert_redirected_to user_public.reload.iri.path
  end

  test 'guest should get show by id user without shortname' do
    get user_path(user_no_shortname.id)

    assert_response 200
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

    ActsAsTenant.current_tenant = argu
    assert_redirected_to user_public.reload.iri.path
  end

  test 'user should get show by id user without shortname' do
    sign_in user

    get user_path(user_no_shortname.id)

    assert_response 200
  end

  test 'user should get show by id user without shortname nq' do
    sign_in user

    get user_path(user_no_shortname.id), headers: argu_headers(accept: :nq)

    assert_response 200
    assert_not_includes(response.body, user_no_shortname.email)
  end

  test 'user should get show user with hidden last name nq' do
    sign_in user

    get user_path(user_hidden_last_name.id), headers: argu_headers(accept: :nq)

    assert_response 200
    expect_no_triple user_hidden_last_name.iri, NS::SCHEMA[:familyName], user_hidden_last_name.last_name
  end

  test 'user should get show self with hidden last name nq' do
    sign_in user_hidden_last_name, Doorkeeper::Application.argu_front_end

    get "/#{argu.url}#{user_path(user_hidden_last_name.id)}", headers: argu_headers(accept: :nq)

    assert_response 200
    user_iri = resource_iri(user_hidden_last_name, root: argu)
    expect_triple user_iri, NS::SCHEMA[:familyName], user_hidden_last_name.last_name
  end

  test 'user should get show non public' do
    sign_in user

    get user_path(user_non_public)

    assert_response 200
  end

  test 'user should get show non public nq' do
    sign_in user, Doorkeeper::Application.argu_front_end

    get "/#{argu.url}#{user_path(user_non_public)}", headers: argu_headers(accept: :nq)

    assert_response 200
    assert_not_includes(response.body, user_non_public.email)
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

  test 'user should show public nq' do
    sign_in user

    get user_path(user_public), headers: argu_headers(accept: :nq)

    assert_response 200
    assert_not_includes(response.body, user_public.email)
  end

  test 'user should show votes own profile' do
    sign_in user_hidden_votes

    get user_path(user_hidden_votes)

    assert_response 200
  end

  test 'user should show votes own profile nq' do
    sign_in user_hidden_votes

    get user_path(user_hidden_votes), headers: argu_headers(accept: :nq)

    assert_response 200
    assert_includes(response.body, user_hidden_votes.email)
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

    get destroy_user_session_path(r: freetown.iri.path)
    assert_redirected_to freetown.iri.path
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
    create_email_mock(
      'confirm_secondary',
      /.+/,
      email: 'secondary@argu.co',
      token_url: /.+/
    )

    assert_difference('EmailAddress.count' => 1,
                      worker_count_string('SendEmailWorker') => 1) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1490174149635': {email: 'secondary@argu.co'}
              },
              current_password: user.password
            }
          }
    end
    user.reload
    assert_equal user.email_addresses.count, 2
    assert_equal user.email_addresses.last.email, 'secondary@argu.co'
    assert_not_equal user.primary_email_record.email, 'secondary@argu.co'

    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
    assert_email_sent
  end

  test 'user should switch primary email' do
    sign_in user
    second_email

    assert_not_equal user.primary_email_record.email, second_email.email

    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1': {email: second_email.email, id: second_email.id}
              },
              primary_email: '[1]',
              current_password: user.password
            }
          }
    end
    user.reload
    assert_equal user.email_addresses.where(primary: true).count, 1
    assert_not_equal user.email_addresses.last.email, second_email.email
    assert_equal user.primary_email_record.email, second_email.email

    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
  end

  test 'user should delete secondary email' do
    sign_in user
    second_email

    assert_difference('EmailAddress.count' => -1,
                      worker_count_string('SendEmailWorker') => 0) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id, _destroy: 'false'},
                '1': {email: second_email.email, id: second_email.id, _destroy: '1'}
              },
              current_password: user.password
            }
          }
    end

    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
  end

  test 'user should not delete primary email' do
    sign_in user
    second_email

    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id, _destroy: '1'},
                '1': {email: second_email.email, id: second_email.id, _destroy: '0'}
              },
              current_password: user.password
            }
          }
    end
  end

  test 'user should change unconfirmed email' do
    sign_in user
    create_email_mock(
      'confirm_secondary',
      /.+/,
      token_url: /.+/,
      email: 'unconfirmed@argu.co'
    )
    ActsAsTenant.with_tenant(argu) { unconfirmed_email }
    assert_email_sent

    create_email_mock(
      'confirm_secondary',
      /.+/,
      token_url: /.+/,
      email: 'changed@argu.co'
    )
    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 1) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '0': {email: user.primary_email_record.email, id: user.primary_email_record.id},
                '1': {email: 'changed@argu.co', id: unconfirmed_email.id}
              },
              current_password: user.password
            }
          }
    end
    unconfirmed_email.reload
    assert_equal unconfirmed_email.email, 'changed@argu.co'

    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
    assert_email_sent
  end

  test 'user should not change confirmed email' do
    sign_in user
    second_email
    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
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

    assert_no_difference('EmailAddress.count') do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
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
    create_email_mock('confirm_secondary', /.+/, email: 'new@email.com', token_url: /.+/)

    assert_difference('EmailAddress.count') do
      put user_path(user),
          params: {
            user: {
              email_addresses_attributes: {
                '99999' => {email: 'new@email.com'}
              },
              form: 'wrong_email',
              r: argu_url('/tokens/email/xxx')
            }
          }
    end

    assert_redirected_to argu_url('/tokens/email/xxx')
    assert_email_sent
  end

  test 'user should not add email of other account on wrong_email' do
    sign_in user_public
    user

    assert_no_difference('EmailAddress.count') do
      put user_path(user_public),
          params: {
            user: {
              email_addresses_attributes: {
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
    get freetown
    assert_equal 'en', client_token_from_cookie['user']['language']
    assert_nil flash[:error]
  end

  test 'guest should get language cookie when visiting dutch forum' do
    get dutch_forum
    assert_equal 'nl', client_token_from_cookie['user']['language']
    assert_nil flash[:error]
  end

  test 'guest should put language' do
    get freetown
    assert_equal 'en', client_token_from_cookie['user']['language']
    put language_users_path(:nl)
    assert_equal 'nl', client_token_from_cookie['user']['language']
    assert_nil flash[:error]
  end

  test 'guest should put language with nested param' do
    get freetown
    assert_equal 'en', client_token_from_cookie['user']['language']
    put '/u/language', params: {user: {language: :nl}}
    assert_equal 'nl', client_token_from_cookie['user']['language']
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
    assert flash[:notice].present?
  end

  ####################################
  # Settings and Update
  ####################################
  test 'user should show settings and all tabs' do
    sign_in user

    get settings_iri('/u')
    assert_user_settings_shown

    %i[general profile authentication notifications privacy advanced].each do |tab|
      get settings_iri('/u', tab: tab)
      assert_user_settings_shown tab
    end
  end

  test 'user should put settings' do
    sign_in user
    profile_id = user.profile.id
    put user_path(user), params: {
      user: {
        profile_attributes: {
          name: 'new name'
        }
      }
    }
    assert_equal profile_id, user.reload.profile.id
  end

  test 'user should update and remove profile_photo and cover_photo' do
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

    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s

    put user_path(user),
        params: {
          user: {
            profile_attributes: {
              id: user.profile.id,
              default_profile_photo_attributes: {
                id: user.profile.default_profile_photo.id,
                content_cache: '',
                used_as: :profile_photo,
                remove_content: '1'
              }
            }
          }
        }
    assert_equal 'name', user.reload.first_name
    assert_nil(user.profile.default_profile_photo.content_identifier)
  end

  let(:place) { create(:place) }
  test 'user should create place and placement on update with postal_code and country code' do
    nominatim_postal_code_valid
    sign_in user

    assert_difference 'Place.count' => 1,
                      'Placement.count' => 1 do
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
    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
  end

  test 'user should create place and placement on update with only country code' do
    nominatim_country_code_only
    sign_in user

    assert_difference 'Place.count' => 1,
                      'Placement.count' => 1 do
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
    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
  end

  test 'user should not create place and placement on update with only postal code' do
    sign_in user

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 0 do
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

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 0 do
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

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 1 do
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
    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
  end

  test 'user should destroy placement on update with blank postal code and country code' do
    sign_in user
    place
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    assert_difference 'Place.count' => 0,
                      'Placement.count' => -1 do
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
    assert_redirected_to settings_iri("/#{argu.url}/u", tab: :general).to_s
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
