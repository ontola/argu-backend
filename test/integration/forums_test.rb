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
    create(:project, parent: holland.edge, edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
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

  let(:tm) { create(:motion, edge_attributes: {trashed_at: DateTime.current}, parent: holland.edge) }
  let(:tq) { create(:question, edge_attributes: {trashed_at: DateTime.current}, parent: holland.edge) }
  let(:tp) { create(:project, edge_attributes: {trashed_at: DateTime.current}, parent: holland.edge) }
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
    get forums_user_path(holland_manager)
    assert_response 302
  end

  test 'guest should get show' do
    # Trigger creation of items
    holland_nested_project_items
    get forum_path(holland)

    general_show(holland)
  end

  test 'guest should not get delete' do
    get delete_forum_path(holland)
    assert_redirected_to new_user_session_path(r: '/holland/delete')
  end

  test 'guest should not delete destroy' do
    holland
    assert_no_difference('Forum.count') do
      delete forum_path(holland)
    end
    assert_redirected_to new_user_session_path(r: '/holland')
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
    get forums_user_path(holland_manager)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'user should get show' do
    # Trigger creation of items
    holland_nested_project_items
    sign_in

    general_show(holland)
  end

  test 'user should not show settings' do
    sign_in

    get settings_forum_path(freetown)
    assert_response 403
    assert_not_authorized
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
    assert_nil assigns(:items), 'Closed forums are leaking content'
  end

  test 'user should not show hidden to non-members' do
    sign_in

    get forum_path(helsinki)
    assert_response 404, 'Hidden forums are visible'
  end

  test 'user should not put update settings' do
    sign_in

    assert_no_difference('holland.reload.lock_version') do
      put forum_path(holland),
          params: {
            forum: {
              name: 'New title',
              bio: 'new contents'
            }
          }
    end

    assert_response 403
    assert_not_authorized
  end

  test 'user should not get delete' do
    sign_in
    get delete_forum_path(holland)
    assert_not_authorized
  end

  test 'user should not delete destroy' do
    holland
    sign_in
    assert_no_difference('Forum.count') do
      delete forum_path(holland)
    end
    assert_not_authorized
  end

  ####################################
  # As Member
  ####################################
  let(:holland_member) { create_member(holland) }
  let(:cologne_member) { create_member(cologne) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'member should get discover' do
    secondary_forums
    sign_in holland_member
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'member should get index' do
    sign_in holland_member
    get forums_user_path(holland_manager)
    assert_response 200

    refute_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'member should get show' do
    # Trigger creation of items
    holland_nested_project_items
    sign_in holland_member

    general_show(holland)
  end

  test 'member should show closed children to members' do
    sign_in cologne_member

    get forum_path(cologne)
    assert_forum_shown(cologne)

    assert cologne.motions.count.positive?
    assert assigns(:items), 'Closed forum content is not present'
  end

  test 'member should show hidden to members' do
    sign_in helsinki_member

    get forum_path(helsinki)
    assert_forum_shown(helsinki)
  end

  test 'member should not put update settings' do
    sign_in holland_member

    assert_no_difference('holland.reload.lock_version') do
      put forum_path(holland),
          params: {
            forum: {
              name: 'New title',
              bio: 'new contents'
            }
          }
    end

    assert_not_authorized
  end

  test 'member should not get delete' do
    sign_in holland_member
    get delete_forum_path(holland)
    assert_not_authorized
  end

  test 'member should not delete destroy' do
    sign_in holland_member
    assert_no_difference('Forum.count') do
      delete forum_path(holland)
    end
    assert_not_authorized
  end

  ####################################
  # As Manager
  ####################################
  let(:holland_manager) { create_manager(holland) }

  test 'manager should get discover' do
    secondary_forums
    sign_in holland_manager
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'manager should not show settings' do
    sign_in holland_manager

    get settings_forum_path(holland),
        params: {tab: :general}
    assert_response 403
  end

  test 'manager should get index' do
    sign_in holland_manager
    get forums_user_path(holland_manager)
    assert_response 200

    assert_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'manager should not get delete' do
    sign_in holland_manager
    get delete_forum_path(holland)
    assert_not_authorized
  end

  test 'manager should not delete destroy' do
    sign_in holland_manager
    assert_no_difference('Forum.count') do
      delete forum_path(holland)
    end
    assert_not_authorized
  end

  ####################################
  # As Admin
  ####################################
  let(:forum_pair) { create_forum_super_admin_pair(type: :populated_forum) }

  test 'super_admin should get discover' do
    secondary_forums
    sign_in create_super_admin(holland)
    get discover_forums_path
    assert_response 200
    assert_select '.box.box-grid', 4
  end

  test 'super_admin should get index' do
    sign_in create_super_admin(holland)
    get forums_user_path(holland_manager)
    assert_response 200

    assert_have_tag response.body,
                    '.box-grid h3',
                    holland.display_name
  end

  test 'super_admin should only show general settings' do
    sign_in create_super_admin(holland)

    get settings_forum_path(holland)
    assert_forum_settings_shown holland

    %i(shortnames banners).each do |tab|
      get settings_forum_path(holland), params: {tab: tab}
      assert_not_authorized
    end
  end

  test 'super_admin should update settings' do
    sign_in create_super_admin(holland)
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

  test 'super_admin should update locale affecting placement' do
    nominatim_netherlands
    sign_in create_super_admin(holland)
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

  test 'super_admin should not show statistics yet' do
    sign_in create_super_admin(holland)

    get statistics_forum_path(holland)
    assert assigns(:forum)
    assert_response 403
  end

  test 'super_admin should get delete' do
    sign_in create_super_admin(holland)
    get delete_forum_path(holland)
    assert_response 200
  end

  test 'super_admin should delete destroy' do
    sign_in create_super_admin(holland)
    assert_difference('Forum.count', -1) do
      delete forum_path(holland)
    end
    assert_redirected_to holland.page
  end

  test 'super_admin should not get new' do
    sign_in create_super_admin(argu)
    assert_raise ActionController::RoutingError do
      get new_portal_forum_path(page: argu)
    end
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

    %i(general shortnames banners).each do |tab|
      get settings_forum_path(holland), params: {tab: tab}
      assert_forum_settings_shown holland
    end
  end

  test 'staff should show statistics' do
    sign_in staff

    inhabitants # Trigger
    get statistics_forum_path(inhabited)
    assert_response 200

    counts = [['Den Haag', '2'], %w(Utrecht 1), %w(Unknown 1)]
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
           edge: holland.edge, role: Grant.roles[:member])
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

  test 'staff should get delete' do
    sign_in staff
    get delete_forum_path(holland)
    assert_response 200
  end

  test 'staff should delete destroy' do
    holland
    sign_in staff
    assert_difference('Forum.count', -1) do
      delete forum_path(holland)
    end
    assert_redirected_to holland.page
  end

  test 'staff should get new' do
    sign_in staff
    get new_portal_forum_path(page: argu)
    assert_response 200
  end

  test 'staff should post create' do
    sign_in staff
    assert_difference('Forum.count', 1) do
      post portal_forums_path params: {
        forum: {
          name: 'New forum',
          locale: 'en-GB',
          shortname_attributes: {shortname: 'new_forum'},
          page_id: argu.id
        }
      }
    end
    assert_redirected_to Forum.last
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

  private

  def included_in_items?(item)
    assigns(:items).map(&:identifier).include?(item.identifier)
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
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed items are visible'

    assert_project_children_visible
    assert_unpublished_content_invisible
  end

  def assert_project_children_visible
    assert included_in_items?(published_project),
           'Published projects are not visible'
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
    assert_not assigns(:items).any?(&:is_trashed?),
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
