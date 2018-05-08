# frozen_string_literal: true

require 'test_helper'

class MenusTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: argu.id,
      order: 0,
      label: 'Custom label',
      label_translation: false,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end
  let!(:settings) { Setting.set('suggested_forums', 'freetown,other_page_forum') }
  let(:user) { create(:user) }

  ####################################
  # As Guest
  ####################################
  test 'Guest should get show application menu' do
    get menus_path, headers: argu_headers(accept: :nt)

    assert_response 200
    expect_triple(RDF::URI(argu_url('/menus/organizations')), RDF[:type], NS::ARGU[:MenuItem])
    expect_triple(RDF::URI(argu_url('/menus/info')), RDF[:type], NS::ARGU[:MenuItem])

    sequence = expect_sequence(RDF::URI(argu_url('/menus/organizations')), NS::ARGU[:menuItems])
    expect_sequence_member(sequence, 0, RDF::URI(argu_url('/menus/organizations', fragment: argu.url)))
    expect_sequence_member(sequence, 1, RDF::URI(argu_url('/menus/organizations', fragment: 'discover')))
    expect_sequence_size(sequence, 2)
  end

  test 'Guest should get show page menu with custom item' do
    get page_menus_path(argu), headers: argu_headers(accept: :nt)

    assert_response 200
    expect_triple(RDF::URI(argu_url("/o/#{argu.url}/menus/navigations")), RDF[:type], NS::ARGU[:MenuItem])
    sequence = expect_sequence(RDF::URI(argu_url("/o/#{argu.url}/menus/navigations")), NS::ARGU[:menuItems])
    expect_sequence_member(sequence, 0, custom_menu_item.iri)
    forums = expect_sequence_member(sequence, 1, RDF::URI("#{argu_url("/o/#{argu.url}/menus/navigations")}#forums"))
    items = expect_sequence(forums, NS::ARGU[:menuItems])
    expect_sequence_member(items, 0, RDF::URI("#{argu_url("/o/#{argu.url}/menus/navigations")}#forums.overview"))
    expect_sequence_member(items, 1, RDF::URI("#{argu_url("/o/#{argu.url}/menus/navigations")}#forums.new_discussion"))
    expect_sequence_member(items, 2, RDF::URI("#{argu_url("/o/#{argu.url}/menus/navigations")}#forums.activity"))
  end

  ####################################
  # As User
  ####################################
  test 'User should get show application menu' do
    sign_in user
    get menus_path, headers: argu_headers(accept: :nt)

    assert_response 200
    expect_triple(RDF::URI(argu_url('/menus/organizations')), RDF[:type], NS::ARGU[:MenuItem])
    expect_triple(RDF::URI(argu_url('/menus/user')), RDF[:type], NS::ARGU[:MenuItem])
    expect_triple(RDF::URI(argu_url('/menus/info')), RDF[:type], NS::ARGU[:MenuItem])

    sequence = expect_sequence(RDF::URI(argu_url('/menus/organizations')), NS::ARGU[:menuItems])
    expect_sequence_member(sequence, 0, RDF::URI(argu_url('/menus/organizations', fragment: Page.last.url)))
    expect_sequence_member(sequence, 1, RDF::URI(argu_url('/menus/organizations', fragment: 'discover')))
    expect_sequence_size(sequence, 2)
  end
end
