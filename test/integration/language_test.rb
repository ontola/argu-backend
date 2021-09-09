# frozen_string_literal: true

require 'test_helper'

class LanguageTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:dutch_forum) { create_forum(initial_public_grant: 'participator', locale: 'nl-NL') }
  let(:user) { create(:user) }

  test 'guest without token should get edit language' do
    get language_form_iri, headers: argu_headers

    assert_enabled_form
  end

  test 'guest without token should not put language' do
    put language_iri,
        params: {user: {language: :nl}},
        headers: argu_headers(bearer: client_token_from_response)

    assert_not_a_user
  end

  test 'guest should put language' do
    sign_in :guest_user

    put language_iri,
        params: {user: {language: :nl}},
        headers: argu_headers(bearer: client_token_from_response)

    assert_language :nl
  end

  test 'user should put language' do
    sign_in user

    assert_equal 'en', user.language

    put language_iri, params: {user: {language: :nl}}

    assert_response :success
    assert_equal 'nl', user.reload.language
  end

  test 'user should not put non-existing language' do
    sign_in user

    assert_equal 'en', user.language

    put language_iri, params: {user: {language: :fake_language}}

    assert_equal 'en', user.reload.language
  end

  private

  def assert_language(language)
    assert_response :success
    assert_equal language.to_s, decoded_token_from_response['user']['language']
  end

  def language_form_iri
    ActsAsTenant.with_tenant(argu) { User.new(singular_resource: true).action(:language).iri }
  end

  def language_iri
    ActsAsTenant.with_tenant(argu) { iri_from_template(:languages_iri) }
  end
end
