# frozen_string_literal: true

require 'test_helper'

class HeadRequestsTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:freetown_motion) { create(:motion, parent: freetown) }
  let(:cairo_motion) { create(:motion, parent: cairo) }
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }
  let(:spectator) { create_spectator(cairo) }

  ####################################
  # As Guest
  ####################################
  test 'guest should head cairo' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head cairo discussions collection' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head cairo.discussion_collection, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head cairo motion' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head cairo_motion, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'guest should head freetown' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head freetown, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown discussions collection' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head freetown.discussion_collection, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'guest should head freetown motion' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    head freetown_motion, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  ####################################
  # As User
  ####################################
  test 'user should head cairo' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head cairo discussions collection' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head cairo.discussion_collection, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head cairo motion' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head cairo_motion, headers: argu_headers(accept: :nq)

    expect_response(403, page: cairo.root)
  end

  test 'user should head freetown' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head freetown, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown by canonical' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head ActsAsTenant.with_tenant(argu) { freetown.canonical_iri }, headers: argu_headers(accept: :nq)

    assert_redirected_to freetown.iri
  end

  test 'user should head freetown discussions collection' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head freetown.discussion_collection, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head freetown motion' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head freetown_motion, headers: argu_headers(accept: :nq)

    expect_response(200)
  end

  test 'user should head non existing website' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head 'https://example.com', headers: argu_headers(accept: :nq)

    expect_response(404, manifest: false)
  end

  test 'user should head non existing path' do
    sign_in user, Doorkeeper::Application.argu_front_end

    head "https://#{argu.iri_prefix}/wrong", headers: argu_headers(accept: :nq)

    expect_response(404)
  end

  ####################################
  # As Spectator
  ####################################
  test 'spectator should head cairo' do
    sign_in spectator, Doorkeeper::Application.argu_front_end

    head cairo, headers: argu_headers(accept: :nq)

    expect_response(200, page: cairo.root)
  end

  test 'spectator should head cairo discussions collection' do
    sign_in spectator, Doorkeeper::Application.argu_front_end

    head cairo.discussion_collection, headers: argu_headers(accept: :nq)

    expect_response(200, page: cairo.root)
  end

  test 'spectator should head cairo motion' do
    sign_in spectator, Doorkeeper::Application.argu_front_end

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