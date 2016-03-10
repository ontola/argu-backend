require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ProfilesHelper

  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:place) { create(:place) }
  let(:placement) { create(:placement) }

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

  test 'user should create place and placement on update with postal_code and country code' do
    sign_in user
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=3583GP').
        to_return(:body => [{
                                place_id: '145555300',
                                address: {
                                    suburb: 'Utrecht',
                                    city: 'Utrecht',
                                    county: 'Bestuur Regio Utrecht',
                                    state: 'Utrecht',
                                    postcode: '3583GP',
                                    country: 'Koninkrijk der Nederlanden',
                                    country_code: 'nl'
                                }
                            }].to_json,
        )

    assert_differences [['Place.count', 1],['Placement.count', 1]] do
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
    sign_in user
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=').
        to_return(:body => [{
                                place_id: '144005013',
                                address: {
                                    country: 'Koninkrijk der Nederlanden',
                                    country_code: 'nl'
                                }
                            }].to_json,
        )

    assert_differences [['Place.count', 1],['Placement.count', 1]] do
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

    assert_differences [['Place.count', 0],['Placement.count', 0]] do
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
    sign_in user
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=WRONG_POSTAL_CODE').
        to_return(:body => [].to_json,
        )

    assert_differences [['Place.count', 0],['Placement.count', 0]] do
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

    assert_differences [['Place.count', 0],['Placement.count', 1]] do
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
    placement = user.build_home_placement(creator: user.profile, place: place)
    placement.save

    assert_differences [['Place.count', 0],['Placement.count', -1]] do
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
