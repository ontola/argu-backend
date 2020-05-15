# frozen_string_literal: true

require 'test_helper'

class ActorsTest < ActionDispatch::IntegrationTest
  define_page
  let(:user) { create(:user) }
  let(:administrator) { create_administrator(argu) }

  test 'guest should not get actors' do
    sign_in :guest_user

    get actors_path, headers: argu_headers(accept: :nq)

    assert_response 401
  end

  test 'user should get get actors' do
    sign_in user

    get actors_path, headers: argu_headers(accept: :nq)

    assert_response 200
    expect_triple(user_iri, RDF.type, nil)
    refute_triple(page_iri, RDF.type, nil)
    expect_triple(LinkedRails.iri(path: actors_path), RDF.first, user_iri)
  end

  test 'administrator should get get actors' do
    sign_in administrator

    get actors_path, headers: argu_headers(accept: :nq)

    assert_response 200
    expect_triple(user_iri(administrator), RDF.type, nil)
    expect_triple(page_iri, RDF.type, nil)
    expect_triple(LinkedRails.iri(path: actors_path), RDF.first, user_iri(administrator))
  end

  private

  def actors_path
    "/#{argu.url}/actors"
  end

  def user_iri(resource = user)
    ActsAsTenant.with_tenant(argu) { resource.iri }
  end

  def page_iri
    argu.iri
  end
end
