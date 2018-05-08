# frozen_string_literal: true

require 'test_helper'

class LocalesTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:dutch_forum) { create_forum(locale: 'nl-NL') }

  test 'set default language' do
    assert_nil cookies['locale']
    get info_path(:about)
    assert_locale 'en'
  end

  test 'set language from edge_tree english' do
    assert_nil cookies['locale']
    get freetown.iri_path
    assert_locale 'en'
  end

  test 'set language from edge_tree dutch' do
    assert_nil cookies['locale']
    get dutch_forum
    assert_locale 'nl'
  end

  test 'set language from r english' do
    assert_nil cookies['locale']
    get new_user_session_path(r: freetown.iri_path)
    assert_locale 'en'
  end

  test 'set language from r dutch' do
    assert_nil cookies['locale']
    get new_user_session_path(r: dutch_forum.iri_path)
    assert_locale 'nl'
  end

  private

  def assert_locale(locale)
    assert_response :success
    assert_equal cookies['locale'], locale
  end
end
