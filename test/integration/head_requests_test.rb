# frozen_string_literal: true

require 'test_helper'

class HeadRequestsTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:demogemeente) { create(:page, url: 'demogemeente', iri_prefix: 'demogemeente.nl') }
  let(:demogemeente_forum) do
    create_forum(parent: demogemeente, url: 'public_forum', initial_public_grant: 'initiator')
  end
  let(:freetown_motion) { create(:motion, parent: freetown) }
  let(:pro_argument) { create(:pro_argument, parent: freetown_motion) }
  let(:cairo_motion) { create(:motion, parent: cairo) }
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }
  let(:spectator) { create_spectator(cairo) }

  ####################################
  # As Guest
  ####################################
  test 'guest should head cairo' do
    sign_in guest_user

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head cairo discussions collection' do
    sign_in guest_user

    head resource_iri(cairo.discussion_collection, root: cairo.root), headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head cairo motion' do
    sign_in guest_user

    head cairo_motion, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head argu' do
    sign_in guest_user

    head argu, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head argu with query param' do
    sign_in guest_user

    head "#{argu.iri}?query=true", headers: argu_headers(accept: :nq)

    assert_redirected_to argu.iri
  end

  test 'guest should head argu settings' do
    sign_in guest_user

    head "#{argu.iri}/settings#container_nodes", headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head demogemeente' do
    sign_in guest_user

    assert_equal demogemeente.iri, 'http://demogemeente.nl/'
    head demogemeente.iri, headers: argu_headers(accept: :nq)

    expect_response(200, page: demogemeente)
  end

  test 'guest should head demogemeente argu.co' do
    sign_in guest_user

    assert_equal demogemeente.iri, 'http://demogemeente.nl/'
    head "#{Rails.application.config.origin}/demogemeente", headers: argu_headers(accept: :nq)

    assert_redirected_to demogemeente.iri.to_s.chomp('/')
  end

  test 'guest should head demogemeente public_forum' do
    sign_in guest_user

    assert_equal demogemeente_forum.iri, 'http://demogemeente.nl/public_forum'
    head demogemeente_forum.iri, headers: argu_headers(accept: :nq)

    expect_response(200, page: demogemeente)
  end

  test 'guest should head demogemeente forum' do
    sign_in guest_user

    assert_equal demogemeente.primary_container_node.iri, 'http://demogemeente.nl/forum'
    head demogemeente.primary_container_node.iri, headers: argu_headers(accept: :nq)

    expect_response(403, page: demogemeente)
  end

  test 'guest should head demogemeente forum argu.co' do
    sign_in guest_user

    assert_equal demogemeente_forum.iri, 'http://demogemeente.nl/public_forum'
    head "#{Rails.application.config.origin}/demogemeente/public_forum", headers: argu_headers(accept: :nq)

    assert_redirected_to demogemeente_forum.iri
  end

  test 'guest should head demogemeente forum from alias' do
    Shortname.create!(shortname: 'demo_alias', owner: demogemeente_forum, primary: false)
    sign_in guest_user

    assert_equal demogemeente_forum.iri, 'http://demogemeente.nl/public_forum'
    head "#{Rails.application.config.origin}/demo_alias", headers: argu_headers(accept: :nq)

    assert_redirected_to demogemeente_forum.iri.to_s
  end

  test 'guest should head freetown' do
    sign_in guest_user

    head freetown, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown discussions collection' do
    sign_in guest_user

    head resource_iri(freetown.discussion_collection, root: freetown.root), headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown motion' do
    sign_in guest_user

    head freetown_motion, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown motion edit page' do
    sign_in guest_user

    head edit_iri(freetown_motion), headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown motion with query params' do
    sign_in guest_user

    head "#{freetown_motion.iri}?query=true", headers: argu_headers(accept: :nq)

    assert_redirected_to freetown_motion.iri
  end

  test 'guest should head redirect pro argument with con route key' do
    sign_in guest_user

    head pro_argument.iri.to_s.sub('/pros/', '/cons/'), headers: argu_headers(accept: :nq)

    assert_redirected_to pro_argument.iri
  end

  test 'guest should head redirect pro argument with m route key' do
    sign_in guest_user

    head pro_argument.iri.to_s.sub('/pros/', '/m/'), headers: argu_headers(accept: :nq)

    assert_redirected_to pro_argument.iri
  end

  test 'guest should head non existing website' do
    sign_in guest_user

    head 'https://example.com', headers: argu_headers(accept: :nq)

    expect_response(404, manifest: false)
  end

  test 'guest should head non existing path' do
    sign_in guest_user

    head "https://#{argu.iri_prefix}/wrong", headers: argu_headers(accept: :nq)

    expect_response(404)
  end
  ####################################
  # As User
  ####################################
  test 'user should head cairo' do
    sign_in user

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head cairo discussions collection' do
    sign_in user

    head resource_iri(cairo.discussion_collection, root: cairo.root), headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head cairo motion' do
    sign_in user

    head cairo_motion, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head freetown' do
    sign_in user

    head freetown, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown discussions collection' do
    sign_in user

    head resource_iri(freetown.discussion_collection, root: freetown.root), headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown motion' do
    sign_in user

    head freetown_motion, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown motion edit page' do
    sign_in user

    head edit_iri(freetown_motion), headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown motion with query params' do
    sign_in user

    head "#{freetown_motion.iri}?query=true", headers: argu_headers(accept: :nq)

    assert_redirected_to freetown_motion.iri
  end

  test 'user should head non existing website' do
    sign_in user

    head 'https://example.com', headers: argu_headers(accept: :nq)

    expect_response(404, manifest: false)
  end

  test 'user should head non existing path' do
    sign_in user

    head "https://#{argu.iri_prefix}/wrong", headers: argu_headers(accept: :nq)

    expect_response(404)
  end

  ####################################
  # As Spectator
  ####################################
  test 'spectator should head cairo' do
    sign_in spectator

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(200, page: cairo.root)
  end

  test 'spectator should head cairo discussions collection' do
    sign_in spectator

    head resource_iri(cairo.discussion_collection, root: cairo.root), headers: argu_headers(accept: :nq)

    expect_response(200, page: cairo.root)
  end

  test 'spectator should head cairo motion' do
    sign_in spectator

    head cairo_motion, headers: argu_headers(accept: :nq)

    expect_response(200, page: cairo.root)
  end

  private

  def expect_response(status, manifest: true, page: argu)
    assert_response(status)
    if manifest
      expect(response.headers['Manifest']).to eq("#{page.iri}/manifest.json")
    else
      expect(response.headers['Manifest']).to be_nil
    end
  end
end
