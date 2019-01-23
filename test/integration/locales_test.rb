# frozen_string_literal: true

require 'test_helper'

class LocalesTest < ActionDispatch::IntegrationTest
  include JWTHelper

  define_freetown
  let(:dutch_forum) { create_forum(locale: 'nl-NL') }

  test 'set default language' do
    get info_path(:about)
    assert_locale 'en'
  end

  test 'set language from edge_tree english' do
    get freetown.iri.path
    assert_locale 'en'
  end

  test 'set language from edge_tree dutch' do
    get dutch_forum
    assert_locale 'nl'
  end

  test 'set language from r english' do
    get new_user_session_path(r: freetown.iri.path)
    assert_locale 'en'
  end

  test 'set language from r dutch' do
    get new_user_session_path(r: dutch_forum.iri.path)
    assert_locale 'nl'
  end

  private

  def assert_locale(locale)
    assert_response :success
    assert_equal token_payload['user']['language'], locale
  end

  def token_payload
    decode_token(Doorkeeper::AccessToken.last.token)
  end
end
