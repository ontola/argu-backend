# frozen_string_literal: true

module LanguageHelper
  def available_locales
    Hash[
      I18n
        .available_locales
        .map { |l| [l.to_sym, {exact_match: NS::ARGU["locale/#{l}"], label: I18n.t(:language, locale: l)}] }
    ]
  end

  def language_for_guest
    language_from_root || I18n.locale.to_s
  end

  def language_from_header
    HttpAcceptLanguage::Parser
      .new(request.headers['HTTP_ACCEPT_LANGUAGE'])
      .compatible_language_from(I18n.available_locales)
  end

  def language_from_root
    ActsAsTenant.current_tenant&.language
  end
end
