require 'test_helper'

class SecurityTest < ActionDispatch::IntegrationTest
  define_freetown

  test 'should block referer spam' do
    spammers = %w(
        http://co.lumb.co/
        http://forum.topic56809347.darodar.com/
        http://site4.floating-share-buttons.com
        http://100dollars-seo.com
    )

    spammers.each do |spammer|
      get forum_path(freetown), {}, 'HTTP_REFERER' => spammer

      assert_response 403
    end

    Rack::Attack.cache.store.clear
  end

  test 'should block parameter spam' do
    spammers = %w(
        co.lumb.co
        forum.topic56809347.darodar.com
        site4.floating-share-buttons.com
        100dollars-seo.com
    )

    spammers.each do |spammer|
      Rack::Attack.cache.store.clear
      get forum_path(freetown, from: spammer)

      assert_response 403
    end

    Rack::Attack.cache.store.clear
  end

  test 'should not block non-spam referer' do
    spammers = [
        'http://facebook.com/',
        'http://argu.co/',
        'http://news.google.com',
        'http://nu.nl/',
        nil
    ]

    spammers.each do |spammer|
      get forum_path(freetown), {}, 'HTTP_REFERER' => spammer

      assert_response 200
    end
  end

  test 'should not block non-spam parameter spam' do
    spammers = [
      'facebook.com',
      'argu.co',
      'news.google.com',
      'nu.nl',
      nil
    ]

    spammers.each do |spammer|
      Rack::Attack.cache.store.clear
      get forum_path(freetown, from: spammer)

      assert_response 200
    end

    Rack::Attack.cache.store.clear
  end

  test 'should block malicious requests' do
    mal_code = [
      '/etc/passwd',
      '../',
      "env X='() { (a)=>\\' bash -c \"echo date\"; cat echo"
    ]

    mal_code.each do |malicious|
      Rack::Attack.cache.store.clear
      get forum_path(freetown, inject: malicious), {}, {}
      assert_response 403
      get forum_path(freetown, inject: malicious), {}, {}
      assert_response 403
      get forum_path(freetown), {}, {}
      assert_response 200
      get forum_path(freetown, inject: malicious), {}, {}
      assert_response 403
      get forum_path(freetown), {}, {}
      assert_response 403
    end

    Rack::Attack.cache.store.clear
  end
end
