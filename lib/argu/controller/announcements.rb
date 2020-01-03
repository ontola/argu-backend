# frozen_string_literal: true

module Argu
  module Controller
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
        @_messages = Pundit.policy_scope(user_context, Announcement)
                       .reject { |a| notices[a.identifier] == 'hidden' }
      end
    end
  end
end
