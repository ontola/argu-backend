# frozen_string_literal: true

require 'test_helper'

class MenusTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      order: 0,
      label: 'Custom label',
      label_translation: false,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end
  let!(:settings) { Setting.set('suggested_forums', [freetown.uuid, SecureRandom.uuid].join(',')) }
  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user: user, profile: user.profile, doorkeeper_scopes: {}) }

  ####################################
  # As Guest
  ####################################
  test 'Guest should get show application menu' do
    get menus_path, headers: argu_headers(accept: :nt)

    assert_response 200
    expect_triple(menu_url(:info), RDF[:type], NS::ONTOLA[:MenuItem])
  end

  test 'Guest should get show page menu with custom item' do
    get "/#{argu.url}/menus", headers: argu_headers(accept: :nt)

    assert_response 200

    navigations_iri = resource_iri(argu.menu(:navigations, user_context), root: argu)
    expect_triple(navigations_iri, RDF[:type], NS::ONTOLA[:MenuItem])
    sequence = expect_sequence(navigations_iri, NS::ONTOLA[:menuItems])
    expect_sequence_member(sequence, 0, RDF::URI("#{navigations_iri}#freetown"))
    expect_sequence_member(sequence, 1, resource_iri(custom_menu_item, root: argu))
    expect_sequence_member(sequence, 2, RDF::URI("#{navigations_iri}#activity"))
  end

  ####################################
  # As User
  ####################################
  test 'User should get show application menu' do
    sign_in user
    get menus_path, headers: argu_headers(accept: :nt)

    assert_response 200
    expect_triple(menu_url(:user), RDF[:type], NS::ONTOLA[:MenuItem])
    expect_triple(menu_url(:info), RDF[:type], NS::ONTOLA[:MenuItem])
  end

  private

  def menu_url(tag, fragment = nil)
    RDF::URI(argu_url("/#{argu.url}/apex/menus/#{tag}", fragment: fragment), frontend: true)
  end
end
