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
    u.shortname = nil
    u.url = nil
    u.iri_cache = nil
    u
  end
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }

  ####################################
  # Show as Guest
  ####################################
  test 'guest should get show by id' do
    sign_in :guest_user

    get resource_iri(user_public, root: argu)

    assert_response :success
  end

  test 'guest should get show by id user without shortname' do
    sign_in :guest_user

    get resource_iri(user_no_shortname, root: argu)

    assert_response 200
  end

  test 'guest should not get show non public' do
    sign_in :guest_user

    get resource_iri(user_non_public, root: argu)

    assert_response 200

    expect_resource_type(NS::ONTOLA[:AnonymousUser])
    expect_triple(requested_iri, NS::SCHEMA[:name], I18n.t('users.anonymous'))
    refute_includes(response.body, user_hidden_votes.first_name)
    refute_includes(response.body, user_hidden_votes.last_name)
    refute_includes(response.body, user_hidden_votes.email)
  end

  test 'guest should get show without feed' do
    sign_in :guest_user

    get resource_iri(user_hidden_votes, root: argu)

    assert_response 200
  end

  test 'guest should get show public' do
    sign_in :guest_user

    get resource_iri(user_public, root: argu)

    assert_response 200
  end

  ####################################
  # Show as User
  ####################################
  test 'user should get show by id' do
    sign_in user

    get resource_iri(user_public, root: argu)

    assert_response :success
  end

  test 'user should get show by id user without shortname' do
    sign_in user

    get resource_iri(user_no_shortname, root: argu)

    assert_response 200
    assert_not_includes(response.body, user_no_shortname.email)
  end

  test 'user should get show user with hidden last name' do
    sign_in user

    get resource_iri(user_hidden_last_name, root: argu)

    assert_response 200
    refute_triple user_hidden_last_name.iri, NS::SCHEMA[:familyName], user_hidden_last_name.last_name
  end

  test 'user should get show self with hidden last name' do
    sign_in user_hidden_last_name

    get resource_iri(user_hidden_last_name, root: argu)

    assert_response 200
    user_iri = resource_iri(user_hidden_last_name, root: argu)
    expect_triple user_iri, NS::SCHEMA[:familyName], user_hidden_last_name.last_name
  end

  test 'user should get show non public' do
    sign_in user

    get resource_iri(user_non_public, root: argu)

    assert_response 200
    assert_not_includes(response.body, user_non_public.email)
  end

  test 'user should get show without feed' do
    sign_in user

    get resource_iri(user_hidden_votes, root: argu)

    assert_response 200

    assert_select '.activity-feed', 0
  end

  test 'user should show public' do
    sign_in user

    get resource_iri(user_public, root: argu)

    assert_response 200
    assert_not_includes(response.body, user_public.email)
  end

  test 'user should show votes own profile' do
    sign_in user_hidden_votes

    get resource_iri(user_hidden_votes, root: argu)

    assert_response 200
    assert_includes(response.body, user_hidden_votes.email)
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
      put resource_iri(user, root: argu),
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

    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
    assert_email_sent
  end

  test 'user should switch primary email' do
    sign_in user
    second_email

    assert_not_equal user.primary_email_record.email, second_email.email

    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put resource_iri(user, root: argu),
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

    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  test 'user should delete secondary email' do
    sign_in user
    second_email

    assert_difference('EmailAddress.count' => -1,
                      worker_count_string('SendEmailWorker') => 0) do
      put resource_iri(user, root: argu),
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

    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  test 'user should not delete primary email' do
    sign_in user
    second_email

    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put resource_iri(user, root: argu),
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
      put resource_iri(user, root: argu),
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

    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
    assert_email_sent
  end

  test 'user should not change confirmed email' do
    sign_in user
    second_email
    assert_difference('EmailAddress.count' => 0,
                      worker_count_string('SendEmailWorker') => 0) do
      put resource_iri(user, root: argu),
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
    sign_in :guest_user

    get users_wrong_email_path(email: 'wrong@email.com')
  end

  test 'user should get wrong_email' do
    sign_in user
    get users_wrong_email_path(email: 'wrong@email.com')
  end

  test 'user with correct email should redirect to r on wrong_email' do
    sign_in user

    assert_no_difference('EmailAddress.count') do
      put resource_iri(user, root: argu),
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

    assert_response :unprocessable_entity
    expect_ontola_action(snackbar: 'Email has already been taken')
  end

  test 'user with other email should redirect to r on wrong_email' do
    sign_in user
    create_email_mock('confirm_secondary', /.+/, email: 'new@email.com', token_url: /.+/)

    assert_difference('EmailAddress.count') do
      put resource_iri(user, root: argu),
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

    assert_response :success
    assert_email_sent
    expect_ontola_action(snackbar: I18n.t('users.registrations.confirm_mail_change_notice'))
  end

  test 'user should not add email of other account on wrong_email' do
    sign_in user_public
    user

    assert_no_difference('EmailAddress.count') do
      put resource_iri(user_public, root: argu),
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

    assert_response 422
    expect_ontola_action(snackbar: 'Email has already been taken')
  end

  ####################################
  # Settings and Update
  ####################################
  test 'user should show settings and all tabs' do
    sign_in user

    get settings_iri('/u', root: argu)
    assert_user_settings_shown

    %i[general profile authentication notifications privacy].each do |tab|
      get settings_iri('/u', root: argu, tab: tab)
      assert_user_settings_shown tab
    end
  end

  test 'user should put settings' do
    sign_in user
    profile_id = user.profile.id
    put user, params: {
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

    put resource_iri(user, root: argu),
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
    assert_response :success
    assert_equal 'name', user.reload.first_name
    assert_equal 2, user.profile.media_objects.reload.count
    assert_equal('profile_photo.png', user.profile.default_profile_photo.content_identifier)
    assert_equal('cover_photo.jpg', user.profile.default_cover_photo.content_identifier)

    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)

    put resource_iri(user, root: argu),
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
      put resource_iri(user, root: argu),
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
    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  test 'user should create place and placement on update with only country code' do
    nominatim_country_code_only
    sign_in user

    assert_difference 'Place.count' => 1,
                      'Placement.count' => 1 do
      put resource_iri(user, root: argu),
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
    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  test 'user should not create place and placement on update with only postal code' do
    sign_in user

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 0 do
      put resource_iri(user, root: argu),
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
    assert_response :unprocessable_entity
  end

  test 'user should not create place and placement on update with wrong postal code' do
    nominatim_postal_code_wrong
    sign_in user

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 0 do
      put resource_iri(user, root: argu),
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
    assert_response :unprocessable_entity
  end

  test 'user should not create place but should create placement on update with cached postal code and country code' do
    sign_in user
    place

    assert_difference 'Place.count' => 0,
                      'Placement.count' => 1 do
      put resource_iri(user, root: argu),
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
    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  test 'user should destroy placement on update with blank postal code and country code' do
    sign_in user
    place
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    assert_difference 'Place.count' => 0,
                      'Placement.count' => -1 do
      put resource_iri(user, root: argu),
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
    assert_response :success
    assert_equal(response.headers['Location'], settings_iri(:u, tab: :general, root: argu).to_s)
  end

  private

  # Asserts that the user settings are shown on a specific tab
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_user_settings_shown(tab = :general)
    assert_response 200
    expect_resource_type(NS::ONTOLA[:MenuItem], iri: settings_iri('/u', root: argu, tab: tab))
  end
end
