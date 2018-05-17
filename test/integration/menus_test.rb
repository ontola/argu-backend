# frozen_string_literal: true

require 'test_helper'

class MenusTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.edge.uuid,
      order: 0,
      label: 'Custom label',
      label_translation: false,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end
  let!(:settings) { Setting.set('suggested_forums', [freetown.edge.uuid, SecureRandom.uuid].join(',')) }
  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user: user, profile: user.profile, doorkeeper_scopes: {}) }

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
    expect_triple(argu.menu(user_context, :navigations).iri, RDF[:type], NS::ARGU[:MenuItem])
    sequence = expect_sequence(argu.menu(user_context, :navigations).iri, NS::ARGU[:menuItems])
    expect_sequence_member(sequence, 0, custom_menu_item.iri)
    forums = expect_sequence_member(sequence, 1, argu.menu(user_context, :navigations).iri(fragment: 'forums'))
    items = expect_sequence(forums, NS::ARGU[:menuItems])
    expect_sequence_member(items, 0, argu.menu(user_context, :navigations).iri(fragment: 'forums.overview'))
    expect_sequence_member(items, 1, argu.menu(user_context, :navigations).iri(fragment: 'forums.new_discussion'))
    expect_sequence_member(items, 2, argu.menu(user_context, :navigations).iri(fragment: 'forums.activity'))
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
