# frozen_string_literal: true

module LanguageHelper
  def available_locales
    Hash[
      I18n
        .available_locales
        .map { |l| [l.to_sym, {exact_match: NS.argu["locale/#{l}"], label: I18n.t(:language, locale: l)}] }
    ]
  end
end
