# frozen_string_literal: true
module AnalyticsHelper
  def staccato_options(opts = {})
    {
      anonymize_ip: true,
      user_id: opts[:uuid] || a_uuid(opts[:user]),
      ssl: true,
      version: ::VERSION.to_s
    }
  end

  def a_uuid(user = nil)
    user ||= current_user
    return unless user.present?
    ary = analytics_token(user).unpack('NnnnnN')
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    format('%08x-%04x-%04x-%04x-%04x%08x', *ary)
  end

  def send_event(**options)
    if ENV['GG_ANALYTICS_ID'].present?
      Staccato
        .tracker(
          ENV['GG_ANALYTICS_ID'],
          client_id(options),
          **staccato_options(options)
        )
        .event(
          category: options[:category],
          action: options[:action],
          label: options[:label],
          value: options[:value]
        )
    end
  rescue Net::ReadTimeout, IOError, EOFError,
         Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE => e
    Bugsnag.notify(e)
  end

  private

  def analytics_token(user)
    salt = user.salt
    ::BCrypt::Engine.hash_secret("#{user.id}#{user.created_at}", salt).from(30)
  end

  def client_id(**options)
    options[:client_id] || defined?(request) && request.session.id
  end
end
