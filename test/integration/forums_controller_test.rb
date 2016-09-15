# frozen_string_literal: true
require 'test_helper'

class ForumsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  define_holland
  define_cologne
  define_helsinki

  let(:project) { create(:project, parent: holland.edge) }
  let(:q1) { create(:question, parent: project.edge) }
  let(:m0) { create(:motion, parent: q1.edge) }
  let(:m1) { create(:motion, parent: project.edge) }

  let(:published_project) do
    create(:project,
           argu_publication: build(:publication),
           parent: holland.edge)
  end
  let(:q2) { create(:question, parent: published_project.edge) }
  let(:m2) { create(:motion, parent: q2.edge) }
  let(:m3) { create(:motion, parent: published_project.edge) }

  let(:q3) { create(:question, parent: holland.edge) }
  let(:m4) { create(:motion, parent: q3.edge) }

  let(:tq) { create(:motion, is_trashed: true, parent: holland.edge) }
  let(:tm) { create(:question, is_trashed: true, parent: holland.edge) }
  let(:tp) { create(:project, trashed_at: DateTime.current, parent: holland.edge) }
  def holland_nested_project_items
    [m0, m1, m2, m3, m4, q1, q2, q3, tq, tm, tp]
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get show' do
    # Trigger creation of items
    holland_nested_project_items
    get forum_path(holland)

    general_show(holland)
  end

  ####################################
  # As User
  ####################################

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
  end

  test 'should not show statistics' do
    sign_in

    get statistics_forum_path(freetown)
    assert_response 403
  end

  test 'user should not leak closed children to non-members' do
    sign_in

    get forum_path(cologne)
    assert_response 200

    assert cologne.motions.count > 0
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

    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:holland_member) { create_member(holland) }
  let(:cologne_member) { create_member(cologne) }
  let(:helsinki_member) { create_member(helsinki) }

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

    assert cologne.motions.count > 0
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

  ####################################
  # As Owner
  ####################################
  let(:forum_pair) { create_forum_owner_pair(type: :populated_forum) }

  test 'owner should show settings and all tabs' do
    sign_in create_owner(holland)

    get settings_forum_path(holland)
    assert_forum_settings_shown holland

    %i(general advanced projects shortnames banners privacy grants).each do |tab|
      get settings_forum_path(holland), params: {tab: tab}
      assert_forum_settings_shown holland, tab
    end
  end

  test 'owner should update settings' do
    sign_in create_owner(holland)
    assert_difference('holland.reload.lock_version', 1) do
      put forum_path(holland),
          params: {
            forum: {
              name: 'new name',
              bio: 'new bio',
              default_profile_photo_attributes: {
                id: holland.default_profile_photo.id,
                image: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png'),
                used_as: 'profile_photo'
              },
              default_cover_photo_attributes: {
                image: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg'),
                used_as: 'cover_photo'
              }
            }
          }
    end

    assert_redirected_to settings_forum_path(holland.url, tab: :general)
    assert_equal 'new name', assigns(:forum).reload.name
    assert_equal 'new bio', assigns(:forum).reload.bio
    assert_equal 'profile_photo.png', assigns(:forum).default_profile_photo.image_identifier
    assert_equal 'cover_photo.jpg', assigns(:forum).default_cover_photo.image_identifier
    assert_equal 2, assigns(:forum).photos.count
  end

  test 'owner should not show statistics yet' do
    sign_in create_owner(holland)

    get statistics_forum_path(holland)
    assert_redirected_to forum_path(holland)
    assert assigns(:forum)
    assert_nil assigns(:tags), "Doesn't assign tags"
    # assert_equal 2, assigns(:tags).length
  end

  ####################################
  # As Manager
  ####################################
  let(:holland_manager) { create_manager(holland) }

  test 'manager should show settings and some tabs' do
    sign_in holland_manager
    %i(general advanced projects shortnames banners).each do |tab|
      get settings_forum_path(holland),
          params: {tab: tab}
      assert_forum_settings_shown(holland, tab)
    end

    [:privacy, :managers].each do |tab|
      get settings_forum_path(holland),
          params: {tab: tab}
      assert_redirected_to forum_path(holland)
    end
  end

  ####################################
  # As Staff
  ####################################
  define_freetown('inhabited')
  let(:staff) { create :user, :staff }
  let(:binnenhof) { create(:place, address: {'city' => 'Den Haag', 'country_code' => 'nl', 'postcode' => '2513AA'}) }
  let(:paleis) { create(:place, address: {'city' => 'Den Haag', 'country_code' => 'nl', 'postcode' => '2517KJ'}) }
  let(:office) { create(:place, address: {'city' => 'Utrecht', 'country_code' => 'nl', 'postcode' => '3583GP'}) }
  let(:nederland) { create(:place, address: {'country_code' => 'nl'}) }
  let(:inhabitants) do
    create(:home_placement, place: office, placeable: create_member(freetown, create(:user)))

    create(:home_placement, place: office, placeable: create_member(inhabited, create(:user)))
    create(:home_placement, place: binnenhof, placeable: create_member(inhabited, create(:user)))
    create(:home_placement, place: paleis, placeable: create_member(inhabited, create(:user)))
    create(:home_placement, place: nederland, placeable: create_member(inhabited, create(:user)))
  end

  test 'staff should show statistics' do
    sign_in staff

    inhabitants # Trigger
    get statistics_forum_path(inhabited)
    assert_response 200

    counts = [['Den Haag', '2'], ['Utrecht', 1], ['Unknown', '1']]
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

  private

  def included_in_items?(item)
    assigns(:items).map(&:identifier).include?(item.identifier)
  end

  # Asserts that the forum is shown on a specific tab
  # @param [Forum] forum The forum to be shown
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_forum_settings_shown(forum, tab = :general)
    assert_response 200
    assert_have_tag response.body,
                    '.tabs-container li:first-child span.icon-left',
                    forum.page.display_name
    assert_have_tag response.body,
                    '.tabs-container li:nth-child(2) span.icon-left',
                    I18n.t('pages.settings.title')
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    I18n.t("forums.settings.menu.#{tab}")
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
end
