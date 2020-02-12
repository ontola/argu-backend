# frozen_string_literal: true

require 'bcrypt'

module AnalyticsHelper
  def a_uuid(user = nil)
    user ||= current_user
    return if user.guest?

    ary = analytics_token(user).unpack('NnnnnN')
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    # rubocop:disable Style/FormatStringToken
    format('%08x-%04x-%04x-%04x-%04x%08x', *ary)
    # rubocop:enable Style/FormatStringToken
  end

  private

  def analytics_token(user)
    salt = user.salt
    ::BCrypt::Engine.hash_secret("#{user.id}#{user.created_at}", salt).from(30)
  end
end
