# frozen_string_literal: true

require 'test_helper'

class MenusTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      label: 'Custom label',
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end
  let!(:child_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      parent_menu: custom_menu_item,
      order: 0,
      label: 'child',
      href: 'https://example.com',
      resource_type: 'Edge',
      resource_id: argu.uuid
    )
  end
  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user: user, profile: user.profile) }

  ####################################
  # As Guest
  ####################################
  test 'Guest should get show application menu' do
    sign_in :guest_user

    get menus_path, headers: argu_headers(accept: :nq)

    assert_response 200
    expect_resource_type(NS::ONTOLA[:MenuItem], iri: menu_url(:info))
  end

  test 'Guest should get show page menu with custom item' do
    sign_in create_guest_user

    get "/#{argu.url}/menus", headers: argu_headers(accept: :nq)

    assert_response 200

    navigations_iri = resource_iri(argu.menu(:navigations, user_context), root: argu)
    expect_resource_type(NS::ONTOLA[:MenuItem], iri: navigations_iri)
    sequence = expect_sequence(navigations_iri, NS::ONTOLA[:menuItems])
    home_menu_iri = RDF::URI("#{navigations_iri}#home")
    freetown_menu_iri = RDF::URI("#{navigations_iri}#menu_item_#{CustomMenuItem.find_by(edge: freetown).id}")
    feed_menu_iri = RDF::URI("#{navigations_iri}#menu_item_#{CustomMenuItem.find_by(resource: argu, order: 100).id}")
    expect_triple(freetown_menu_iri, NS::ONTOLA[:href], freetown.iri)
    expect_triple(feed_menu_iri, NS::ONTOLA[:href], feeds_iri(argu))
    expect_sequence_member(sequence, 0, home_menu_iri)
    expect_sequence_member(sequence, 1, freetown_menu_iri)
    expect_sequence_member(sequence, 2, resource_iri(custom_menu_item, root: argu))
    expect_sequence_member(sequence, 3, feed_menu_iri)
    expect_triple(resource_iri(custom_menu_item, root: argu), NS::ONTOLA[:menuItems], nil)
  end

  ####################################
  # As User
  ####################################
  test 'User should get show application menu' do
    sign_in user
    get menus_path, headers: argu_headers(accept: :nq)

    assert_response 200
    expect_resource_type(NS::ONTOLA[:MenuItem], iri: menu_url(:user))
    expect_resource_type(NS::ONTOLA[:MenuItem], iri: menu_url(:info))
  end

  private

  def menu_url(tag, fragment = nil)
    RDF::URI(["#{argu.iri}/menus/#{tag}", fragment].compact.join('#'))
  end

  def menus_path
    "#{argu.iri}/menus"
  end
end
