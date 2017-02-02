# frozen_string_literal: true
require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo

  let(:user) { create(:user) }
  let(:user_public) { create(:user, profile: create(:profile)) }
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }

  ####################################
  # Show as Guest
  ####################################
  test 'guest should get show by id' do
    get user_path(user_public.id)

    assert_redirected_to user_public
  end

  test 'guest should not get show non public' do
    get user_path(initialize_votes(user_non_public))

    assert_response 403
    assert_show_no_votes(user_non_public)
  end

  test 'guest should get show public' do
    get user_path(initialize_votes(user_public))

    assert_response 200

    assert_show_visible_votes(user_public)
  end

  test 'guest should get show hidden' do
    get user_path(initialize_votes(user_hidden_votes))
    assert_response 200
    assert_show_no_votes(user_hidden_votes)
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

    get user_path(initialize_votes(user_non_public))

    assert_show_visible_votes(user_non_public)
  end

  test 'user should get show public' do
    sign_in user

    get user_path(initialize_votes(user_public))

    assert_response 200
    assert_show_visible_votes(user_public)
  end

  test 'user should get show hidden' do
    sign_in user

    get user_path(initialize_votes(user_hidden_votes))
    assert_response 200
    assert_show_no_votes(user_hidden_votes)
  end

  test 'user should show votes own profile' do
    sign_in user_hidden_votes

    get user_path(initialize_votes(user_hidden_votes))
    assert_response 200
    assert_show_all_untrashed_votes(user_hidden_votes)
  end

  ####################################
  # Show as Member
  ####################################
  let(:member) { create_member(cairo) }

  test 'member should get show public' do
    sign_in member

    get user_path(initialize_votes(user_public))

    assert_response 200
    assert_show_all_untrashed_votes(user_public)
  end

  ####################################
  # Settings and Update
  ####################################
  test 'user should show settings and all tabs' do
    sign_in user

    get settings_path
    assert_user_settings_shown

    %i(general profile authentication notifications privacy advanced).each do |tab|
      get settings_path(tab: tab)
      assert_user_settings_shown tab
    end
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
                image: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
              },
              default_cover_photo_attributes: {
                image: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg')
              }
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
    assert_redirected_to settings_path(tab: :general)
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
    assert_redirected_to settings_path(tab: :general)
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
    assert_redirected_to settings_path(tab: :general)
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
    assert_redirected_to settings_path(tab: :general)
  end

  private

  def assert_show_no_votes(user)
    assert user.profile.votes.any? { |v| !v.forum.open? }
    assert user.profile.votes.any? { |v| v.parent_model.voteable.is_trashed? }
    %i(pro neutral con).each do |side|
      assert assigns(:collection)[side][:collection].empty? if assigns(:collection).try(:[], side).present?
    end
  end

  def assert_show_all_untrashed_votes(user)
    assert user.profile.votes.any? { |v| !v.forum.open? }
    assert user.profile.votes.any? { |v| v.parent_model.voteable.is_trashed? }
    %i(pro neutral con).each do |side|
      assert assigns(:collection)[side][:collection].all? { |v| !v.parent_model.voteable.is_trashed? }
    end

    expected_votes = user_public
                       .profile
                       .votes
                       .select { |v| !v.parent_model.voteable.is_trashed? && v.voteable_type == 'Motion' }
                       .pluck(:id)
    selected_votes = %i(pro neutral con).map { |side| assigns(:collection)[side][:collection].map(&:id) }.flatten
    assert_empty expected_votes - selected_votes
  end

  def assert_show_visible_votes(user)
    assert user.profile.votes.any? { |v| !v.forum.open? }
    assert user.profile.votes.any? { |v| v.parent_model.voteable.is_trashed? }
    %i(pro neutral con).each do |side|
      assert assigns(:collection)[side][:collection].all? do |v|
        v.forum.open? && !v.parent_model.voteable.is_trashed?
      end
    end
    %i(pro neutral con).map { |side| assigns(:collection)[side][:collection].map(&:id) }.flatten.present?
  end

  # Asserts that the user settings are shown on a specific tab
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_user_settings_shown(tab = :general)
    assert_response 200
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    tab.to_s.capitalize
  end

  def initialize_votes(user)
    public_motion = create(:motion, parent: freetown.edge)
    create(:vote, for: :neutral, parent: public_motion.default_vote_event.edge, creator: user.profile, publisher: user)
    argument = create(:argument, parent: public_motion.edge)
    create(:vote, for: :neutral, parent: argument.edge, creator: user.profile, publisher: user)

    closed_motion = create(:motion, parent: cairo.edge, creator: user.profile)
    create(:vote, for: :pro, parent: closed_motion.default_vote_event.edge, creator: user.profile, publisher: user)

    trashed_motion = create(:motion,
                            parent: freetown.edge,
                            creator: user.profile,
                            edge_attributes: {trashed_at: DateTime.current})
    create(:vote, for: :pro, parent: trashed_motion.default_vote_event.edge, creator: user.profile, publisher: user)
    user
  end
end
