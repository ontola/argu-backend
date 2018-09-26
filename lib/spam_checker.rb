# frozen_string_literal: true

class SpamChecker
  include Rakismet::Model
  attr_accessor :email, :content
  rakismet_attrs user_ip: '0.0.0.0'

  def initialize(opts = {})
    self.email = opts[:email]
    self.content = opts[:content]
  end

  def spam?
    super
    SpamVerdict.create!(
      verdict: @_spam,
      content: content,
      email: email,
      http_headers: Rakismet.request.http_headers,
      ip: Rakismet.request.user_ip,
      referrer: Rakismet.request.referrer,
      user_agent: Rakismet.request.user_agent
    )
    @_spam
  end
end
