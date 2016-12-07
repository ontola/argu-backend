# frozen_string_literal: true
require 'test_helper'

class SourcesControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  let(:page) { create(:page) }
  let(:source) { create(:source, parent: page.edge, shortname: 'source') }

  ####################################
  # As Quest
  ####################################
  test 'guest should not show settings and all tabs' do
    get settings_page_source_path(page, source)
    assert_not_a_user
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

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(page) }

  test 'owner should show settings and all tabs' do
    sign_in page.owner.profileable

    get settings_page_source_path(page, source)
    assert_source_settings_shown source

    %i(general privacy groups).each do |tab|
      get settings_page_source_path(source), params: {tab: tab}
      assert_source_settings_shown source, tab
    end
  end

  test 'owner should update settings' do
    sign_in page.owner.profileable

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

  test 'staff should show settings and some tabs' do
    sign_in staff

    get settings_page_source_path(page, source)
    assert_source_settings_shown source

    %i(general privacy groups).each do |tab|
      get settings_page_source_path(source), params: {tab: tab}
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
