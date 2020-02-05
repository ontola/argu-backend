# frozen_string_literal: true

require 'test_helper'

class LanguageTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:dutch_forum) { create_forum(public_grant: 'participator', locale: 'nl-NL') }
  let(:user) { create(:user) }

  test 'guest should set freetown language' do
    get freetown, headers: argu_headers

    assert_language :en
  end

  test 'guest should set dutch language' do
    get dutch_forum, headers: argu_headers

    assert_language :nl
  end

  test 'guest should put language' do
    get freetown, headers: argu_headers

    assert_language :en

    put language_iri(:nl), headers: argu_headers(bearer: client_token_from_response)

    assert_language :nl
  end

  test 'user should put language' do
    sign_in user

    assert_equal 'en', user.language

    put language_iri(:nl)

    assert_equal 'nl', user.reload.language
  end

  test 'user should not put non-existing language' do
    sign_in user

    assert_equal 'en', user.language

    put language_iri(:fake_language)

    assert_equal 'en', user.reload.language
  end

  private

  def assert_language(language)
    assert_equal language.to_s, decoded_token_from_response['user']['language']
  end

  def language_iri(language)
    ActsAsTenant.with_tenant(argu) { iri_from_template(:languages_iri, language: language) }
  end
end
