class Rack::Attack
  SPAMMERS = [
      /co\.lumb\.co/,
      /darodar/,
      /-seo.com/,
      /erot.co/,
      /howtostopreferralspam.eu/,
      /floating-share-buttons.com/
  ].freeze

  HACKERS = [
      %r{/etc/passwd},
      %r{\.\./},
      %r{\(\)\s*\{\s*\(.*\)\s*=>}
  ].freeze

  unless Rails.env.test?
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip unless req.path.starts_with?('/assets')
    end

    throttle('req/ip', limit: 5, period: 20.seconds) do |req|
      if (!Rails.env.test? && req.post? && %w(/oauth /actors /users /connect /setup /move /convert /v/ /c/).any? { |n| req.path.include?(n) }) ||
         %w(/users/auth).any? { |n| req.path.include?(n) }
        req.ip
      end
    end
  end

  blacklist('block referer spam') do |req|
    Rack::Attack::Fail2Ban.filter(req.ip, maxretry: 0, findtime: 10.minutes, bantime: 5.hours) do
      SPAMMERS.find { |spammer| req.referer =~ spammer }
    end
  end

  # Block requests containing '/etc/password' in the params.
  # After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
  blacklist('fail2ban pentesters') do |req|
    # `filter` returns truthy value if request fails, or if it's from a previously banned IP
    # so the request is blocked

    Rack::Attack::Fail2Ban.filter(req.ip, maxretry: 3, findtime: 10.minutes, bantime: 60.minutes) do
      # The count for the IP is incremented if the return value is truthy.
      HACKERS.any? do |r|
        CGI.unescape(req.query_string) =~ r
      end
    end
  end

end
