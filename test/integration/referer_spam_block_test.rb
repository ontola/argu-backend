require 'test_helper'

class RefererSpamBlockTest < ActionDispatch::IntegrationTest

  test 'should block referer spam' do
    spammers = %w(
        http://co.lumb.co/
        http://forum.topic56809347.darodar.com/
        http://site4.floating-share-buttons.com
        http://100dollars-seo.com
    )

    spammers.each do |spammer|
      get forum_path(forums(:utrecht)), {}, { 'HTTP_REFERER' => spammer }

      assert_response 403
    end
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
      get forum_path(forums(:utrecht)), {}, { 'HTTP_REFERER' => spammer }

      assert_response 200
    end
  end

end
