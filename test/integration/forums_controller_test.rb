require 'test_helper'

class ForumsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  let(:freetown) { create(:forum, name: 'freetown') }
  let!(:holland) { create(:populated_forum, name: 'holland') }
  let!(:cologne) { create(:closed_populated_forum, name: 'cologne') }
  let!(:helsinki) { create(:hidden_populated_forum, name: 'helsinki') }

  let(:project) { create(:project, :unpublished, forum: holland) }
  let(:q1) { create(:question, forum: holland, project: project) }
  let(:m0) { create(:motion, forum: holland, project: project, question: q1) }
  let(:m1) { create(:motion, forum: holland, project: project) }

  let(:published_project) { create(:project, :published, forum: holland) }
  let(:q2) { create(:question, forum: holland, project: published_project) }
  let(:m2) { create(:motion, forum: holland, project: published_project, question: q2) }
  let(:m3) { create(:motion, forum: holland, project: published_project) }

  let(:tq) { create(:motion, :trashed, forum: holland) }
  let(:tm) { create(:question, :trashed, forum: holland) }
  let(:tp) { create(:project, :trashed_at, forum: holland) }
  def holland_nested_project_items
    [m0, m1, m2, m3, q1, q2, tq, tm, tp]
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
    assert_redirected_to forum_path(freetown), 'Settings are publicly visible'
  end

  test 'should not show statistics' do
    sign_in

    get statistics_forum_path(freetown)
    assert_redirected_to forum_path(freetown), 'Statistics are publicly visible'
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

  test 'user should not put update on others question' do
    sign_in

    put forum_path(holland),
        question: {
          title: 'New title',
          content: 'new contents'
        }
    assert_redirected_to forum_path(holland), 'Others can update questions'
  end

  test 'user should get selector' do
    sign_in

    get selector_forums_path
    assert_response 200, 'Selector broke'
    assert_not_nil assigns(:forums)
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

  ####################################
  # As Owner
  ####################################
  let(:forum_pair) { create_forum_owner_pair(type: :populated_forum) }

  test 'owner should show settings and all tabs' do
    forum, owner = forum_pair
    sign_in owner

    get settings_forum_path(forum)
    assert_forum_settings_shown forum

    [:general, :advanced, :groups, :privacy, :managers].each do |tab|
      get settings_forum_path(forum), tab: tab
      assert_forum_settings_shown forum, tab
    end
  end

  test 'owner should update settings' do
    forum, owner = forum_pair
    sign_in owner

    assert_difference('forum.reload.lock_version', 1) do
      put forum_path(forum),
          forum: {
            name: 'new name',
            bio: 'new bio',
            default_profile_photo_attributes: {
              id: forum.default_profile_photo.id,
              image: fixture_file_upload(File.expand_path('test/files/profile_photo.png'), 'image/png'),
              used_as: 'profile_photo'
            },
            default_cover_photo_attributes: {
              image: fixture_file_upload(File.expand_path('test/files/cover_photo.jpg'), 'image/jpg'),
              used_as: 'cover_photo'
            }
          }
    end

    assert_redirected_to settings_forum_path(forum.url, tab: :general)
    assert_equal 'new name', assigns(:forum).reload.name
    assert_equal 'new bio', assigns(:forum).reload.bio
    assert_equal 'profile_photo.png', assigns(:forum).default_profile_photo.image_identifier
    assert_equal 'cover_photo.jpg', assigns(:forum).default_cover_photo.image_identifier
    assert_equal 2, assigns(:forum).photos.count
  end

  test 'owner should not show statistics yet' do
    forum, owner = forum_pair
    sign_in owner

    get statistics_forum_path(forum)
    assert_redirected_to forum_path(forum)
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

    [:general, :advanced, :groups].each do |tab|
      get settings_forum_path(holland),
          tab: tab
      assert_forum_settings_shown(holland, tab)
    end

    [:privacy, :managers].each do |tab|
      get settings_forum_path(holland),
          tab: tab
      assert_redirected_to forum_path(holland)
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
                    forum.display_name
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    tab.to_s.capitalize
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

  def assert_unpublished_content_invisible
    assert included_in_items?(published_project),
           'Published projects are not visible'
    assert_have_tag response.body, 'h3.question-t .list-item span', q2.title,
                    "Published projects' questions are not visible"
    assert_have_tag response.body, "##{published_project.identifier} h3.motion-t .list-item span", m3.title,
                    "Published projects' motions are not visible"
  end
end
