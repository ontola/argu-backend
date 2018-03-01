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
    get forum_path(freetown)
    assert_locale 'en'
  end

  test 'set language from edge_tree dutch' do
    assert_nil cookies['locale']
    get forum_path(dutch_forum)
    assert_locale 'nl'
  end

  test 'set language from r english' do
    assert_nil cookies['locale']
    get new_user_session_path(r: forum_path(freetown))
    assert_locale 'en'
  end

  test 'set language from r dutch' do
    assert_nil cookies['locale']
    get new_user_session_path(r: forum_path(dutch_forum))
    assert_locale 'nl'
  end

  private

  def assert_locale(locale)
    assert_response :success
    assert_equal cookies['locale'], locale
  end
end
