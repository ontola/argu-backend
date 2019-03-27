# frozen_string_literal: true

require 'test_helper'

class ForumsTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  define_holland
  define_cairo(
    'forum_with_placement',
    attributes: {
      url: 'forum_with_placement',
      shortname_attributes: {shortname: 'forum_with_placement'},
      custom_placement_attributes: {
        lat: 1.0,
        lon: 1.0,
        placement_type: 'custom'
      }
    }
  )
  define_cologne
  define_helsinki

  let(:draft_motion) do
    create(:motion, parent: holland, argu_publication_attributes: {draft: true})
  end
  let(:draft_question) do
    create(:question, parent: holland, argu_publication_attributes: {draft: true})
  end
  let(:motion_in_draft_question) { create(:motion, parent: draft_question) }

  let(:question) { create(:question, parent: holland) }
  let(:motion) { create(:motion, parent: question) }
  let(:motion_in_question) { create(:question, parent: holland) }

  let(:trashed_motion) { create(:motion, trashed_at: Time.current, parent: holland) }
  let(:trashed_question) { create(:question, trashed_at: Time.current, parent: holland) }

  let(:tm) { create(:motion, trashed_at: Time.current, parent: holland) }
  let(:tq) { create(:question, trashed_at: Time.current, parent: holland) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get discover' do
    secondary_forums
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'guest should not get index' do
    get forums_user_path(holland_moderator)
    assert_response 302
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get discover' do
    secondary_forums
    sign_in
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'user should get index' do
    sign_in user
    get forums_user_path(user)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'should not show statistics' do
    sign_in

    get statistics_iri(freetown)
    assert_response 403
    assert_not_authorized
  end

  test 'user should not leak closed children to non-members' do
    sign_in

    get cologne
    assert_response 200

    assert cologne.motions.count.positive?
    assert_nil assigns(:children), 'Closed forums are leaking content'
  end

  test 'user should not show hidden to non-members' do
    sign_in

    get helsinki
    assert_response 404, 'Hidden forums are visible'
  end

  ####################################
  # As Initiator
  ####################################
  let(:holland_initiator) { create_initiator(holland) }
  let(:cologne_initiator) { create_initiator(cologne) }
  let(:helsinki_initiator) { create_initiator(helsinki) }

  test 'initiator should get discover' do
    secondary_forums
    sign_in holland_initiator
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'initiator should get index' do
    sign_in holland_initiator
    get forums_user_path(holland_initiator)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'initiator should show closed children to members' do
    sign_in cologne_initiator

    get cologne
    assert_forum_shown(cologne)

    assert cologne.motions.count.positive?
    assert assigns(:children), 'Closed forum content is not present'
  end

  test 'initiator should show hidden to members' do
    sign_in helsinki_initiator

    get helsinki
    assert_forum_shown(helsinki)
  end

  ####################################
  # As Moderator
  ####################################
  let(:holland_moderator) { create_moderator(holland) }

  test 'moderator should get discover' do
    secondary_forums
    sign_in holland_moderator
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'moderator should get index' do
    sign_in holland_moderator
    get forums_user_path(holland_moderator)
    assert_response 200

    assert_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  ####################################
  # As Administrator
  ####################################
  let(:forum_pair) { create_forum_administrator_pair(type: :populated_forum) }
  let(:holland_administrator) { create_administrator(holland) }

  test 'administrator should get discover' do
    secondary_forums
    sign_in holland_administrator
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'administrator should get index' do
    sign_in holland_administrator
    get forums_user_path(holland_administrator)
    assert_response 200

    assert_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'administrator should put update' do
    sign_in holland_administrator
    put holland,
        params: {
          forum: {
            name: 'new name',
            bio: 'new bio',
            default_profile_photo_attributes: {
              id: holland.default_profile_photo.id,
              content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png'),
              used_as: 'profile_photo'
            },
            default_cover_photo_attributes: {
              content: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg'),
              used_as: 'cover_photo'
            }
          }
        }

    assert_redirected_to holland.iri.path
    assert_not_equal holland.updated_at.iso8601(6), holland.reload.updated_at.iso8601(6)
    assert_equal 'new name', holland.name
    assert_equal 'new bio', holland.bio
    assert_equal 'profile_photo.png', holland.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', holland.default_cover_photo.content_identifier
    assert_equal 2, holland.media_objects.count
  end

  test 'administrator should update shortname' do
    sign_in holland_administrator
    put holland,
        params: {
          forum: {
            url: 'new_url'
          }
        }
    assert_redirected_to holland.reload.iri.path
    updated_holland = Forum.find_by(uuid: holland.uuid)
    assert_equal 'new_url', updated_holland.url
    assert(
      updated_holland
        .widgets
        .last
        .resource_iri
        .all? { |iri, _predicate| iri.end_with?('/new_url/discussions?display=grid&type=infinite') }
    )
    assert_equal "#{updated_holland.parent.iri}/new_url", updated_holland.iri
  end

  test 'administrator should update locale affecting placement' do
    nominatim_netherlands
    sign_in holland_administrator
    assert_equal holland.reload.places.first.country_code, 'GB'
    assert_difference('Placement.count' => 0) do
      put holland,
          params: {
            forum: {
              locale: 'nl-NL'
            }
          }
    end
    assert_not_equal holland.updated_at.iso8601(6), holland.reload.updated_at.iso8601(6)
    assert_equal holland.reload.locale, 'nl-NL'
    assert_equal holland.reload.places.first.country_code, 'NL'
  end

  test 'administrator should show statistics' do
    sign_in holland_administrator

    get statistics_iri(holland)
    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  define_freetown('inhabited')
  let(:staff) { create :user, :staff }
  let(:transfer_to) { create :page }
  let(:binnenhof) { create(:place, address: {'city' => 'Den Haag', 'country_code' => 'nl', 'postcode' => '2513AA'}) }
  let(:paleis) { create(:place, address: {'city' => 'Den Haag', 'country_code' => 'nl', 'postcode' => '2517KJ'}) }
  let(:office) { create(:place, address: {'city' => 'Utrecht', 'country_code' => 'nl', 'postcode' => '3583GP'}) }
  let(:nederland) { create(:place, address: {'country_code' => 'nl'}) }
  let(:inhabitants) do
    create(:home_placement, place: office, placeable: create_follower(freetown, create(:user)))

    create(:home_placement, place: office, placeable: create_follower(inhabited, create(:user)))
    create(:home_placement, place: binnenhof, placeable: create_follower(inhabited, create(:user)))
    create(:home_placement, place: paleis, placeable: create_follower(inhabited, create(:user)))
    create(:home_placement, place: nederland, placeable: create_follower(inhabited, create(:user)))
  end

  test 'staff should get discover' do
    secondary_forums
    sign_in staff
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'staff should show statistics' do
    sign_in staff

    inhabitants # Trigger
    get statistics_iri(inhabited)
    assert_response 200

    counts = [['Den Haag', '2'], %w[Utrecht 1], %w[Unknown 1]]
    assert_select '.additional-stats' do |element|
      assert_select element, 'tr' do |rows|
        assert_equal 3, rows.count
        element.each_with_index do |row, i|
          assert_select row, 'td:first', text: counts[i][0]
          assert_select row, 'td:last', text: counts[i][1]
        end
      end
    end
  end

  test 'staff should transfer' do
    sign_in staff
    create(:grant,
           group: create(:group, parent: holland.root),
           edge: holland,
           grant_set: GrantSet.participator)
    assert_difference('transfer_to.forums.reload.count' => 1, 'holland.reload.grants.size' => -1) do
      post resource_iri(Move.new(edge: holland)), params: {move: {new_parent_id: transfer_to.uuid}}
    end
    assert_equal holland.parent, transfer_to
    holland.instance_variable_set('@root', nil)
    assert_equal holland.root, transfer_to
    assert_equal holland.questions.first.root, transfer_to
  end

  test 'staff should transfer by iri' do
    sign_in staff
    create(:grant,
           group: create(:group, parent: holland.root),
           edge: holland,
           grant_set: GrantSet.participator)
    assert_difference('transfer_to.forums.reload.count' => 1, 'holland.reload.grants.size' => -1) do
      post resource_iri(Move.new(edge: holland)), params: {move: {new_parent_id: transfer_to.iri}}
    end
    assert_equal holland.parent, transfer_to
    holland.instance_variable_set('@root', nil)
    assert_equal holland.root, transfer_to
    assert_equal holland.questions.first.root, transfer_to
  end

  test 'staff should post create forum with latlon' do
    sign_in staff

    assert_difference('Forum.count' => 1, 'Placement.count' => 2, 'Place.count' => 1) do
      post collection_iri(argu, :forums), params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          url: 'new_forum',
          custom_placement_attributes: {
            lat: 1.0,
            lon: 1.0,
            placement_type: 'custom'
          }
        }
      }
    end

    assert_equal 1, Forum.last.placements.first.lat
    assert_equal 1, Forum.last.placements.first.lon
  end

  test 'staff should post create forum json_api' do
    sign_in :service

    assert_difference('OpenDataPortal.count' => 1) do
      post collection_iri(argu, :open_data_portals), params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          url: 'new_forum',
          public_grant: :participator
        }
      }, headers: argu_headers(accept: :json_api)
    end
    assert_response 201
  end

  test 'creator should put update forum change latlon' do
    sign_in staff
    forum_with_placement

    assert_difference('Placement.count' => 0, 'Place.count' => 1) do
      put forum_with_placement,
          params: {
            forum: {
              custom_placement_attributes: {
                id: forum_with_placement.custom_placement.id,
                lat: 2.0,
                lon: 2.0
              }
            }
          }
    end

    forum_with_placement.reload
    assert_equal 2, forum_with_placement.custom_placement.lat
    assert_equal 2, forum_with_placement.custom_placement.lon
  end

  test 'staff should put update motion remove latlon' do
    sign_in staff
    forum_with_placement

    assert_difference('Motion.count' => 0, 'Placement.count' => -1, 'Place.count' => 0) do
      put forum_with_placement,
          params: {
            forum: {
              custom_placement_attributes: {
                id: forum_with_placement.custom_placement.id,
                _destroy: 'true'
              }
            }
          }
    end
  end

  test 'staff should delete destory forum with confirmation string' do
    sign_in staff

    assert_difference('Forum.count', -1) do
      delete freetown.iri.path,
             params: {forum: {confirmation_string: 'remove'}}
    end
  end

  test 'staff should not delete destroy forum without confirmation string' do
    sign_in staff

    assert_difference('Forum.count', 0) do
      delete freetown.iri.path,
             params: {
               forum: {}
             }
    end
  end

  ####################################
  # As Service
  ####################################
  test 'service should post create forum' do
    sign_in :service

    assert_difference('Forum.count' => 1, 'Widget.discussions.count' => 1) do
      post collection_iri(argu, :forums), params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          url: 'new_forum'
        }
      }, headers: argu_headers(accept: :json)
    end
    iri = "#{Forum.last.iri}/discussions?display=grid&type=infinite"
    assert_equal Forum.last.widgets.last.resource_iri, [[iri, nil]]
  end

  test 'service should post create ori forum' do
    sign_in :service

    assert_difference('OpenDataPortal.count' => 1, 'Widget.discussions.count' => 0) do
      post collection_iri(argu, :open_data_portals), params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          url: 'new_forum'
        }
      }, headers: argu_headers(accept: :json)
    end
  end

  private

  def included_in_items?(item)
    assigns(:children).map(&:identifier).include?(item.identifier)
  end

  def assert_forum_shown(forum)
    assert_response 200
    assert_have_tag response.body,
                    '.cover-switcher .dropdown-trigger span:first-child',
                    forum.display_name
  end

  # @param [Symbol] response The expected visibility in `%w(show list)`
  def general_show(record = freetown)
    get record
    assert_forum_shown(record)
    assert_not_nil assigns(:children)

    assert_not assigns(:children).any?(&:is_trashed?), 'Trashed items are visible'

    assert_content_visible
    assert_unpublished_content_invisible
  end

  def assert_content_visible
    assert included_in_items?(motion),
           'Motions are not visible'
    assert included_in_items?(question),
           'Questions are not visible'
    assert_not included_in_items?(motion_in_question),
               'Question motions are visible'
  end

  def assert_unpublished_content_invisible
    assert_not assigns(:children).any?(&:is_trashed?),
               'Trashed items are visible'
    assert_not included_in_items?(draft_question),
               'Unpublished questions are visible'
    assert_not included_in_items?(draft_motion),
               'Unpublished motions are visible'
    assert_not included_in_items?(motion_in_draft_question),
               "Unpublished questions' motions are visible"
  end

  def secondary_forums
    holland
    cologne
    helsinki
  end
end
