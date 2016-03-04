module LanguageHelper
  def language_dropdown_items
    {
      title: I18n.t(:language, locale: I18n.locale),
      image: { url: path_to_image("flags/#{I18n.locale}"), title: I18n.t(:language, locale: I18n.locale)},
      sections: [
          {
              items: I18n.available_locales.collect {|language_code|
                    link_item(
                        I18n.t(:language, locale: language_code),
                        language_users_path(language_code),
                        image: path_to_image("flags/#{language_code}"),
                        data: { method: :put }
                    )
                  }
          }
      ],
      triggerClass: ''
    }
  end

  def language_select_items
    I18n.available_locales.collect {|language_code| [I18n.t(:language, locale: language_code), language_code]}
  end
end
