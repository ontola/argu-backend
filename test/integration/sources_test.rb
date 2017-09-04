# frozen_string_literal: true

require 'test_helper'

class SourcesTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  let(:page) { create(:page) }
  let(:source) { create(:source, parent: page.edge, shortname: 'source', public_grant: 'member') }

  ####################################
  # As Quest
  ####################################
  test 'guest should not show settings and all tabs' do
    get settings_page_source_path(page, source)
    assert_not_a_user
  end

  test 'guest should get show JSON API with ids' do
    get page_source_path(page_id: page.id, id: source.id, format: :json_api)
    assert_response 200
  end

  test 'guest should get show JSON API with shortnames' do
    get page_source_path(page_id: page.url, id: source.url, format: :json_api)
    assert_response 200
  end

  ####################################
  # As member
  ####################################
  let(:member) { create_member(page) }

  test 'member should not show settings and all tabs' do
    sign_in member

    get settings_page_source_path(page, source)
    assert_not_authorized
  end

  test 'member should get show JSON API with ids' do
    sign_in member
    get page_source_path(page_id: page.id, id: source.id, format: :json_api)
    assert_response 200
  end

  test 'member should get show JSON API with shortnames' do
    sign_in member
    get page_source_path(page_id: page.url, id: source.url, format: :json_api)
    assert_response 200
  end

  ####################################
  # As super admin
  ####################################
  let(:super_admin) { create_super_admin(page) }

  test 'super_admin should show settings and all tabs' do
    sign_in super_admin

    get settings_page_source_path(page, source)
    assert_source_settings_shown source

    %i[general].each do |tab|
      get settings_page_source_path(page, source), params: {tab: tab}
      assert_source_settings_shown source, tab
    end
  end

  test 'super_admin should update settings' do
    sign_in super_admin

    put page_source_path(source.page, source),
        params: {
          source: {
            name: 'new name',
            iri_base: 'whitelist'
          }
        }
    assert_redirected_to settings_page_source_path(source.page, source.url, tab: :general)
    source.reload
    assert_equal 'new name', source.name
    assert_equal 'whitelist', source.iri_base
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get new' do
    sign_in staff

    get new_portal_source_path(page: page.url)
    assert_response 200
  end

  test 'staff should post create' do
    sign_in staff

    assert_difference('Source.count', 1) do
      post portal_sources_path,
           params: {
             source: {
               page_id: page.id,
               name: 'name',
               iri_base: 'whitelist',
               shortname: 'source'
             }
           }
    end
    assert_redirected_to portal_path
  end

  test 'staff should get show JSON API with ids' do
    sign_in staff
    get page_source_path(page_id: page.id, id: source.id, format: :json_api)
    assert_response 200
  end

  test 'staff should get show JSON API with shortnames' do
    sign_in staff
    get page_source_path(page_id: page.url, id: source.url, format: :json_api)
    assert_response 200
  end

  test 'staff should show settings and some tabs' do
    sign_in staff

    get settings_page_source_path(page, source)
    assert_source_settings_shown source

    %i[general].each do |tab|
      get settings_page_source_path(page, source), params: {tab: tab}
      assert_source_settings_shown source, tab
    end
  end

  test 'staff should update settings' do
    sign_in staff

    put page_source_path(source.page, source),
        params: {
          source: {
            name: 'new name',
            iri_base: 'whitelist'
          }
        }
    assert_redirected_to settings_page_source_path(source.page, source.url, tab: :general)
    source.reload
    assert_equal 'new name', source.name
    assert_equal 'whitelist', source.iri_base
  end

  private

  # Asserts that the source is shown on a specific tab
  # @param [Source] source The source to be shown
  # @param [Symbol] tab The tab to be shown (defaults to :general)
  def assert_source_settings_shown(source, tab = :general)
    assert_response 200
    assert_have_tag response.body,
                    '.tabs-container li:first-child span.icon-left',
                    source.page.display_name
    assert_have_tag response.body,
                    '.tabs-container li:nth-child(2) span.icon-left',
                    I18n.t('pages.settings.title')
    assert_have_tag response.body,
                    '.settings-tabs .tab--current .icon-left',
                    I18n.t("sources.settings.menu.#{tab}")
  end
end
