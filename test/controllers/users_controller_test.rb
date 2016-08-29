require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown

  ####################################
  # As Guest
  ####################################
  let(:user) { create(:user) }
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }

  test 'guest should get show when public' do
    get :show, id: user

    assert_response 200
  end

  test 'guest should not get show when not public' do
    get :show, id: user_non_public

    assert_redirected_to root_path
    assert_nil assigns(:collection)
  end

  test 'guest should get show with platform access' do
    initialize_user2_votes
    get :show,
        id: user2,
        at: create(:access_token)

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  test 'guest should put language' do
    request.env['HTTP_REFERER'] = root_url
    assert_nil cookies['locale']
    put :language, locale: :en
    assert_equal 'en', cookies['locale']
  end

  ####################################
  # As User
  ####################################
  let(:other_user) { create(:user) }

  test 'user should get show non public' do
    sign_in user

    get :show, id: user_non_public

    assert_response 200
  end

  let(:amsterdam) { create_forum }
  let(:utrecht) { create_forum }
  let(:user2) { create_member(amsterdam, create_member(utrecht)) }

  test 'user should get show' do
    initialize_user2_votes
    sign_in user

    get :show, id: user2

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).granted_edges.where(owner_type: 'Forums').pluck(:owner_id)
    assert assigns(:collection)
             .values
             .all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  test 'user should not show all votes' do
    sign_in initialize_user2_votes

    get :show, id: user2
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal user2
                   .profile
                   .votes_questions_motions
                   .reject(&:is_trashed?)
                   .length,
                 assigns(:collection)
                   .values
                   .map {|i| i[:collection].length }.inject(&:+),
                 'Not all/too many votes are shown'
  end

  test 'user should not show votes when not votes are hidden' do
    sign_in user

    get :show, id: user_hidden_votes
    assert_response 200
    assert_not assigns(:collection)
  end

  test 'user should show votes when viewing own profile' do
    sign_in user_hidden_votes

    get :show, id: user_hidden_votes
    assert_response 200
    assert assigns(:collection)
  end

  test 'user should not show votes of trashed objects' do
    sign_in user2

    get :show, id: initialize_user2_votes

    assert_response 200
    assert assigns(:collection)[:pro][:collection].length > 0
    assert_not assigns(:collection)[:pro][:collection].any? { |v| v.voteable.is_trashed? }
  end

  test 'user should show settings and all tabs' do
    sign_in user

    get :settings
    assert_user_settings_shown

    %i(general profile authentication notifications privacy advanced).each do |tab|
      get :settings, tab: tab
      assert_user_settings_shown tab
    end
  end

  test 'user should put language' do
    user = create_member(utrecht, create_member(amsterdam))
    sign_in user
    request.env['HTTP_REFERER'] = root_url
    assert_equal 'en', user.language
    put :language, locale: :nl
    assert_equal 'nl', user.reload.language
    assert_nil flash[:error]
  end

  test 'user should not put non-existing language' do
    user = create_member(utrecht, create_member(amsterdam))
    sign_in user
    request.env['HTTP_REFERER'] = root_url
    assert_equal 'en', user.language
    put :language, locale: :fake_language
    assert_equal 'en', user.reload.language
    assert flash[:error].present?
  end

  test 'user should update profile_photo and cover_photo' do
    nominatim_postal_code_valid
    sign_in user

    put :update,
        id: user.url,
        user: {
          first_name: 'name',
          profile_attributes: {
            id: user.profile.id,
            default_profile_photo_attributes: {
              id: user.profile.default_profile_photo.id,
              image: uploaded_file_object(Photo, :image, open_file('profile_photo.png'))
            },
            default_cover_photo_attributes: {
              image: uploaded_file_object(Photo, :image, open_file('cover_photo.jpg'))
            }
          }
        }
    assert_equal 'name', user.reload.first_name
    assert_equal 2, user.profile.photos.reload.count
    assert_equal('profile_photo.png', user.profile.default_profile_photo.image_identifier)
    assert_equal('cover_photo.jpg', user.profile.default_cover_photo.image_identifier)

    assert_redirected_to settings_path(tab: :general)
  end

  let(:place) { create(:place) }
  test 'user should create place and placement on update with postal_code and country code' do
    nominatim_postal_code_valid
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put :update,
          id: user.url,
          user: {
            first_name: 'name',
            home_placement_attributes: {
              postal_code: '3583GP',
              country_code: 'NL'
            }
          }
    end
    assert_redirected_to settings_path(tab: :general)
  end

  test 'user should create place and placement on update with only country code' do
    nominatim_country_code_only
    sign_in user

    assert_differences [['Place.count', 1],
                        ['Placement.count', 1]] do
      put :update,
          id: user.url,
          user: {
            first_name: 'name',
            home_placement_attributes: {
              postal_code: '',
              country_code: 'NL'
            }
          }
    end
    assert_redirected_to settings_path(tab: :general)
  end

  test 'user should not create place and placement on update with only postal code' do
    sign_in user

    assert_differences [['Place.count', 0],
                        ['Placement.count', 0]] do
      put :update,
          id: user.url,
          user: {
            first_name: 'name',
            home_placement_attributes: {
              postal_code: '3583GP',
              country_code: ''
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
          user: {
            first_name: 'name',
            home_placement_attributes: {
              postal_code: 'wrong_postal_code',
              country_code: 'NL'
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
          user: {
            first_name: 'name',
            home_placement_attributes: {
              postal_code: '3583GP',
              country_code: 'NL'
            }
          }
    end
    assert_redirected_to settings_path(tab: :general)
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
          user: {
            first_name: 'name',
            home_placement_attributes: {
              id: placement.id,
              postal_code: '',
              country_code: ''
            }
          }
    end
    assert_redirected_to settings_path(tab: :general)
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

  def initialize_user2_votes
    motion1 = create(:motion, parent: utrecht.edge)
    motion3 = create(:motion, parent: amsterdam.edge, creator: user2.profile)
    motion4 = create(:motion, parent: freetown.edge, creator: user2.profile, is_trashed: true)
    argument1 = create(:argument, parent: motion1.edge)
    create(:vote, for: :neutral, parent: motion1.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :pro, parent: motion3.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :neutral, parent: argument1.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :pro, parent: motion4.edge, voter: user2.profile, publisher: user2)
    user2
  end
end
