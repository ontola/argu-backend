module BannersHelper

  def options_for_banner_audiences
    Banner.audiences.keys.map { |n| [I18n.t("banners.audiences.#{n}"), n] }
  end

end
