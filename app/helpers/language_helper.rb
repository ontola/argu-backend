module LanguageHelper
  def language_select_items
    I18n.available_locales.collect {|language_code| [I18n.t(:language, locale: language_code), language_code]}
  end
end
