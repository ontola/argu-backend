# frozen_string_literal: true

module Argu
  module Announcements
    extend ActiveSupport::Concern

    included do
      helper_method :collect_announcements
    end

    private

    def collect_announcements
      return @_messages if @_messages.present?

      notices = stubborn_hgetall('announcements') || {}
      notices = JSON.parse(notices) if notices.present? && notices.is_a?(String)
      @_messages = policy_scope(Announcement)
                         .reject { |a| notices[a.identifier] == 'hidden' }
    end
  end
end
