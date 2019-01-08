# frozen_string_literal: true

module AnnouncementsHelper
  def options_for_announcement_audiences
    Announcement.audiences.keys.map { |n| [I18n.t("banners.audiences.#{n}"), n] }
  end
end
