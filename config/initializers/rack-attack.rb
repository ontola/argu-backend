class Rack::Attack

  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless req.path.starts_with?('/assets')
  end

  throttle('req/ip', :limit => 5, :period => 20.seconds) do |req|
    if (req.post? && %w(/oauth /actors /users /connect /setup /move /convert /v/ /c/).any? { |n| req.path.include?(n) }) ||
       %w(/users/auth).any? { |n| req.path.include?(n) }
      req.ip
    end
  end

  blacklist('block referer spam') do |request|
    spammers = [
        /co\.lumb\.co/,
        /darodar/,
        /-seo.com/,
        /erot.co/,
        /howtostopreferralspam.eu/,
        /floating-share-buttons.com/
    ]
    spammers.find { |spammer| request.referer =~ spammer }
  end

end
