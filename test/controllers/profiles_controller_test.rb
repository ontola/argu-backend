# frozen_string_literal: true
require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers, ProfilesHelper

  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:place) { create(:place) }

  ####################################
  # As User
  ####################################
  test 'user should get edit profile with own profile' do
    sign_in user

    get :edit, id: user.url

    assert_response 200
    assert_equal user, assigns(:resource), ''
    assert_equal user.profile, assigns(:profile), ''
  end

  test 'user should not get edit profile with other profile' do
    sign_in user

    get :edit, id: user2.url

    assert_response 302
    assert_equal user2, assigns(:resource)
    assert_equal user2.profile, assigns(:profile)
  end

  test 'user should update profile_photo and cover_photo' do
    nominatim_postal_code_valid
    sign_in user

    put :update,
        id: user.url,
        profile: {
          default_profile_photo_attributes: {
            id: user.profile.default_profile_photo.id,
            image: uploaded_file_object(Photo, :image, open_file('profile_photo.png'))
          },
          default_cover_photo_attributes: {
            image: uploaded_file_object(Photo, :image, open_file('cover_photo.jpg'))
          },
          profileable_attributes: {
            first_name: 'name'
          }
    }
    assert_equal 'name', user.reload.first_name
    assert_equal 2, assigns(:profile).photos.reload.count
    assert_equal('profile_photo.png', assigns(:profile).default_profile_photo.image_identifier)
    assert_equal('cover_photo.jpg', assigns(:profile).default_cover_photo.image_identifier)

    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should create place and placement on update with postal_code and country code' do
    nominatim_postal_code_valid
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put :update,
          id: user.url,
          profile: {
            profileable_attributes: {
              home_placement_attributes: {
                postal_code: '3583GP',
                country_code: 'NL'
              },
              first_name: 'name'
            }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should create place and placement on update with only country code' do
    nominatim_country_code_only
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put :update,
          id: user.url,
          profile: {
              profileable_attributes: {
                  home_placement_attributes: {
                      postal_code: '',
                      country_code: 'NL'
                  },
                  first_name: 'name'
              }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should not create place and placement on update with only postal code' do
    sign_in user

    assert_differences [['Place.count', 0],
                        ['Placement.count', 0]] do
      put :update,
          id: user.url,
          profile: {
              profileable_attributes: {
                  home_placement_attributes: {
                      postal_code: '3583GP',
                      country_code: ''
                  },
                  first_name: 'name'
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
      put :update,
          id: user.url,
          profile: {
              profileable_attributes: {
                  home_placement_attributes: {
                      postal_code: 'wrong_postal_code',
                      country_code: 'NL'
                  },
                  first_name: 'name'
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
      put :update,
          id: user.url,
          profile: {
              profileable_attributes: {
                  home_placement_attributes: {
                    postal_code: '3583GP',
                    country_code: 'NL'
                  },
                  first_name: 'name'
              }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should destroy placement on update with blank postal code and country code' do
    sign_in user
    place
    placement = user.build_home_placement(creator: user.profile, publisher: user, place: place)
    placement.save

    assert_differences [['Place.count', 0],
                        ['Placement.count', -1]] do
      put :update,
          id: user.url,
          profile: {
              profileable_attributes: {
                  home_placement_attributes: {
                      id: placement.id,
                      postal_code: '',
                      country_code: ''
                  },
                  first_name: 'name'
              }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end
end
