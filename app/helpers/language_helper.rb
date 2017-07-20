# frozen_string_literal: true
module LanguageHelper
  def language_dropdown_items
    {
      title: I18n.locale.upcase,
      image: {
        url: path_to_image("flags/#{I18n.locale}.svg"),
        title: I18n.t(:language, locale: I18n.locale)
      },
      sections: [
        {
          items: I18n.available_locales.collect do |language_code|
            link_item(
              I18n.t(:language, locale: language_code),
              language_users_path(language_code),
              image: path_to_image("flags/#{language_code}.svg"),
              data: {method: :put}
            )
          end
        }
      ],
      triggerClass: ''
    }
  end

  def language_from_edge_tree; end

  def language_from_header
    HttpAcceptLanguage::Parser
      .new(request.headers['HTTP_ACCEPT_LANGUAGE'])
      .compatible_language_from(I18n.available_locales)
  end

  def language_select_items
    I18n.available_locales.collect do |language_code|
      [I18n.t(:language, locale: language_code), language_code]
    end
  end

  def locale_select_items
    ISO3166::Country.codes
      .flat_map do |code|
        ISO3166::Country.new(code).languages_official.map do |language|
          ["#{ISO3166::Country.translations(I18n.locale)[code]} (#{language.upcase})", "#{language}-#{code}"]
        end
      end
  end

  def set_guest_language
    cookies['locale'] ||= language_from_edge_tree || language_from_header || I18n.locale.to_s
  end
end
