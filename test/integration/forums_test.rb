# frozen_string_literal: true

require 'test_helper'

class ForumsTest < ActionDispatch::IntegrationTest
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

  test 'guest should get show by upcased shortname' do
    sign_in :guest_user

    get freetown.iri.to_s.gsub('freetown', 'Freetown'), headers: argu_headers

    assert_response :success
    expect_resource_type(NS.argu[:Forum], iri: freetown.iri)
  end

  test 'guest should get show by upcased page shortname' do
    sign_in :guest_user

    get freetown.iri.to_s.gsub("/#{argu.url}/", "/#{argu.url.upcase}/"), headers: argu_headers
    assert_redirected_to freetown.iri.to_s
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'should not show statistics' do
    sign_in

    get statistics_iri(freetown), headers: argu_headers
    assert_response 403
    assert_not_authorized
  end

  test 'user should not show hidden to non-members' do
    sign_in

    get helsinki, headers: argu_headers
    assert_response 404, 'Hidden forums are visible'
  end

  ####################################
  # As Initiator
  ####################################
  let(:holland_initiator) { create_initiator(holland) }
  let(:helsinki_initiator) { create_initiator(helsinki) }

  test 'initiator should show hidden to members' do
    sign_in helsinki_initiator

    get helsinki, headers: argu_headers
    assert_response :success
  end

  ####################################
  # As Administrator
  ####################################
  let(:forum_pair) { create_forum_administrator_pair(type: :populated_forum) }
  let(:holland_administrator) { create_administrator(holland) }

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
        },
        headers: argu_headers

    assert_response :success
    assert_not_equal holland.updated_at.iso8601(6), holland.reload.updated_at.iso8601(6)
    assert_equal 'new name', holland.name
    assert_equal 'new bio', holland.bio
    assert_equal 'profile_photo.png', holland.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', holland.default_cover_photo.content_identifier
    assert File.exist?(holland.default_cover_photo.content.cover.file.path)
    assert_equal 2, holland.media_objects.count
  end

  test 'administrator should update shortname' do
    sign_in holland_administrator
    assert_includes holland.widgets.discussions.first.resource_iri.first.first, holland.root_relative_iri.to_s
    put holland,
        params: {
          forum: {
            url: 'new_url'
          }
        },
        headers: argu_headers
    assert_response :success
    updated_holland = Forum.find_by(uuid: holland.uuid)
    assert_equal 'new_url', updated_holland.url
    assert(
      updated_holland
        .widgets
        .last
        .resource_iri
        .all? { |iri, _predicate| iri.end_with?('/new_url/discussions?display=grid&type=infinite') }
    )
    assert_includes(
      updated_holland.widgets.discussions.first.resource_iri.first.first,
      updated_holland.root_relative_iri.to_s
    )
    assert_equal "#{updated_holland.parent.iri}/new_url", updated_holland.iri
    updated_holland.custom_actions.map(&:href).all? do |iri|
      iri.match?(%r{#{Regexp.escape(updated_holland.parent.iri)}/new_url})
    end
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
          },
          headers: argu_headers
    end
    assert_not_equal holland.updated_at.iso8601(6), holland.reload.updated_at.iso8601(6)
    assert_equal holland.reload.locale, 'nl-NL'
    assert_equal holland.reload.places.first.country_code, 'NL'
  end

  test 'administrator should show statistics' do
    sign_in holland_administrator

    get statistics_iri(holland), headers: argu_headers
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

  test 'staff should show statistics' do
    sign_in staff

    inhabitants # Trigger
    get statistics_iri(inhabited), headers: argu_headers
    assert_response :success
  end

  test 'staff should post create forum with latlon' do
    sign_in staff

    assert_difference('Forum.count' => 1, 'Placement.count' => 2, 'Place.count' => 1, 'CustomAction.count' => 3) do
      post collection_iri(argu, :forums),
           params: {
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
           },
           headers: argu_headers
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
          url: 'new_forum'
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
          },
          headers: argu_headers
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
          },
          headers: argu_headers
    end
    expect_triple(
      forum_with_placement.iri,
      NS.schema.location,
      NS.sp.Variable,
      NS.ontola[:remove]
    )
  end

  test 'staff should delete destory forum with confirmation string' do
    sign_in staff

    assert_difference('Forum.count', -1) do
      delete freetown.iri.path,
             params: {forum: {confirmation_string: 'remove'}},
             headers: argu_headers
    end
  end

  test 'staff should not delete destroy forum without confirmation string' do
    sign_in staff

    assert_difference('Forum.count', 0) do
      delete freetown.iri.path,
             params: {
               forum: {}
             },
             headers: argu_headers
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
    helsinki
  end
end
