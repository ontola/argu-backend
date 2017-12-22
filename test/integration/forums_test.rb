# frozen_string_literal: true

require 'test_helper'

class ForumsTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  define_holland
  define_cairo(
    'forum_with_placement',
    attributes: {
      edge_attributes: {
        placements_attributes: {
          '0' => {
            lat: 1.0,
            lon: 1.0,
            placement_type: 'custom'
          }
        }
      }
    }
  )
  define_cologne
  define_helsinki

  let(:project) do
    create(:project, parent: holland.edge, edge_attributes: {argu_publication_attributes: {draft: true}})
  end
  let(:q1) { create(:question, parent: project.edge) }
  let(:m0) { create(:motion, parent: q1.edge) }
  let(:m1) { create(:motion, parent: project.edge) }

  let(:published_project) { create(:project, parent: holland.edge) }
  let(:q2) { create(:question, parent: published_project.edge) }
  let(:m2) { create(:motion, parent: q2.edge) }
  let(:m3) { create(:motion, parent: published_project.edge) }

  let(:q3) { create(:question, parent: holland.edge) }
  let(:m4) { create(:motion, parent: q3.edge) }

  let(:tm) { create(:motion, edge_attributes: {trashed_at: Time.current}, parent: holland.edge) }
  let(:tq) { create(:question, edge_attributes: {trashed_at: Time.current}, parent: holland.edge) }
  let(:tp) { create(:project, edge_attributes: {trashed_at: Time.current}, parent: holland.edge) }
  def holland_nested_project_items
    [m0, m1, m2, m3, m4, q1, q2, q3, tq, tm, tp]
  end

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

  test 'user should get discover' do
    secondary_forums
    sign_in
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'user should get index' do
    sign_in
    get forums_user_path(holland_moderator)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'should not show statistics' do
    sign_in

    get statistics_forum_path(freetown)
    assert_response 403
    assert_not_authorized
  end

  test 'user should not leak closed children to non-members' do
    sign_in

    get forum_path(cologne)
    assert_response 200

    assert cologne.motions.count.positive?
    assert_nil assigns(:children), 'Closed forums are leaking content'
  end

  test 'user should not show hidden to non-members' do
    sign_in

    get forum_path(helsinki)
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
    get forums_user_path(holland_moderator)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'initiator should show closed children to members' do
    sign_in cologne_initiator

    get forum_path(cologne)
    assert_forum_shown(cologne)

    assert cologne.motions.count.positive?
    assert assigns(:children), 'Closed forum content is not present'
  end

  test 'initiator should show hidden to members' do
    sign_in helsinki_initiator

    get forum_path(helsinki)
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

  test 'administrator should get discover' do
    secondary_forums
    sign_in create_administrator(holland)
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'administrator should get index' do
    sign_in create_administrator(holland)
    get forums_user_path(holland_moderator)
    assert_response 200

    assert_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'administrator should only show general settings' do
    sign_in create_administrator(holland)

    get settings_forum_path(holland)
    assert_forum_settings_shown holland

    %i[shortnames banners].each do |tab|
      get settings_forum_path(holland), params: {tab: tab}
      assert_not_authorized
    end
  end

  test 'administrator should update settings' do
    sign_in create_administrator(holland)
    assert_difference('holland.reload.lock_version', 1) do
      put forum_path(holland),
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
    end

    assert_redirected_to settings_forum_path(holland.url, tab: :general)
    assert_equal 'new name', assigns(:forum).reload.name
    assert_equal 'new bio', assigns(:forum).reload.bio
    assert_equal 'profile_photo.png', assigns(:forum).default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', assigns(:forum).default_cover_photo.content_identifier
    assert_equal 2, assigns(:forum).media_objects.count
  end

  test 'administrator should update locale affecting placement' do
    nominatim_netherlands
    sign_in create_administrator(holland)
    assert_equal holland.edge.reload.places.first.country_code, 'GB'
    assert_differences([['holland.reload.lock_version', 1], ['Placement.count', 0]]) do
      put forum_path(holland),
          params: {
            forum: {
              locale: 'nl-NL'
            }
          }
    end
    assert_equal holland.reload.locale, 'nl-NL'
    assert_equal holland.edge.reload.places.first.country_code, 'NL'
  end

  test 'administrator should show statistics' do
    sign_in create_administrator(holland)

    get statistics_forum_path(holland)
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

  test 'staff should show settings and all tabs' do
    sign_in staff

    get settings_forum_path(holland)
    assert_forum_settings_shown holland

    %i[general shortnames banners].each do |tab|
      get settings_forum_path(holland), params: {tab: tab}
      assert_forum_settings_shown holland
    end
  end

  test 'staff should show statistics' do
    sign_in staff

    inhabitants # Trigger
    get statistics_forum_path(inhabited)
    assert_response 200

    counts = [['Den Haag', '2'], %w[Utrecht 1], %w[Unknown 1]]
    assert_select '.city-table' do |element|
      assert_select element, '.city-row' do |rows|
        assert_equal 3, rows.count
        element.each_with_index do |row, i|
          assert_select row, '.city', text: counts[i][0]
          assert_select row, '.city-count', text: counts[i][1]
        end
      end
    end
  end

  test 'staff should transfer' do
    sign_in staff
    create(:grant,
           group: create(:group, parent: holland.page.edge),
           edge: holland.edge, role: Grant.roles[:participator])
    assert_equal holland.edge.grants.size, 2
    put forum_path(holland),
        params: {
          forum: {
            page_id: transfer_to.id
          }
        }
    holland.reload
    assert_equal holland.edge.parent, transfer_to.edge
    assert_equal holland.edge.grants.size, 1
  end

  test 'staff should post create forum with latlon' do
    sign_in staff

    assert_differences([['Forum.count', 1], ['Placement.count', 2], ['Place.count', 1]]) do
      post portal_forums_path params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          shortname_attributes: {shortname: 'new_forum'},
          edge_attributes: {
            placements_attributes: {
              '0' => {
                lat: 1.0,
                lon: 1.0,
                placement_type: 'custom'
              }
            }
          },
          page_id: argu.id
        }
      }
    end

    assert_equal 1, Forum.last.edge.placements.first.lat
    assert_equal 1, Forum.last.edge.placements.first.lon
  end

  test 'creator should put update forum change latlon' do
    sign_in staff
    forum_with_placement

    assert_differences([['Placement.count', 0], ['Place.count', 1]]) do
      put forum_path(forum_with_placement),
          params: {
            forum: {
              edge_attributes: {
                placements_attributes: {
                  '0' => {
                    id: forum_with_placement.edge.custom_placements.first.id,
                    lat: 2.0,
                    lon: 2.0
                  }
                }
              }
            }
          }
    end

    forum_with_placement.edge.reload
    assert_equal 2, forum_with_placement.edge.custom_placements.first.lat
    assert_equal 2, forum_with_placement.edge.custom_placements.first.lon
  end

  test 'staff should put update motion remove latlon' do
    sign_in staff
    forum_with_placement

    assert_differences([['Motion.count', 0], ['Placement.count', -1], ['Place.count', 0]]) do
      put forum_path(forum_with_placement),
          params: {
            forum: {
              edge_attributes: {
                placements_attributes: {
                  '0' => {
                    id: forum_with_placement.edge.custom_placements.first.id,
                    _destroy: 'true'
                  }
                }
              }
            }
          }
    end
  end

  test 'staff should delete destory forum with confirmation string' do
    sign_in staff

    assert_difference('Forum.count', -1) do
      delete forum_path(freetown),
             params: {forum: {confirmation_string: 'remove'}}
    end
  end

  test 'staff should not delete destory forum without confirmation string' do
    sign_in staff

    assert_difference('Forum.count', 0) do
      delete forum_path(freetown),
             params: {
               forum: {}
             }
    end
  end

  private

  def included_in_items?(item)
    assigns(:children).map(&:identifier).include?(item.edge.identifier)
  end

  # Asserts that the forum is shown on a specific tab
  # @param [Forum] forum The forum to be shown
  def assert_forum_settings_shown(forum)
    assert_response 200
    assert_have_tag response.body,
                    '.tabs-container li:first-child span.icon-left',
                    forum.page.display_name
    assert_have_tag response.body,
                    '.tabs-container li:nth-child(2) span.icon-left',
                    I18n.t('pages.settings.title')
    assert_have_tag response.body,
                    'header h1',
                    forum.display_name
  end

  def assert_forum_shown(forum)
    assert_response 200
    assert_have_tag response.body,
                    '.cover-switcher .dropdown-trigger span:first-child',
                    forum.display_name
  end

  # @param [Symbol] response The expected visibility in `%w(show list)`
  def general_show(record = freetown)
    get forum_path(record)
    assert_forum_shown(record)
    assert_not_nil assigns(:children)

    assert_not assigns(:children).any?(&:is_trashed?), 'Trashed items are visible'

    assert_project_children_visible
    assert_unpublished_content_invisible
  end

  def assert_project_children_visible
    assert included_in_items?(q3),
           'Questions are not visible'
    assert_not included_in_items?(m4),
               'Question motions are visible'
    assert_not included_in_items?(m3),
               'Project motions are visible'
    assert_not included_in_items?(q2),
               'Project questions are visible'
    assert_not included_in_items?(m3),
               'Project Question motions are visible'
  end

  def assert_unpublished_content_invisible
    assert_not assigns(:children).any?(&:is_trashed?),
               'Trashed items are visible'
    assert_not included_in_items?(project),
               'Unpublished projects are visible'
    assert_not included_in_items?(q1),
               "Unpublished projects' questions are visible"
    assert_not included_in_items?(m0),
               "Unpublished projects' nested motions are visible"
    assert_not included_in_items?(m1),
               "Unpublished projects' motions are visible"
  end

  def secondary_forums
    holland
    cologne
    helsinki
  end
end
