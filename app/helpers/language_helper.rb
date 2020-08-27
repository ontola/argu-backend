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
    language_from_edge_tree || language_from_r || language_from_root || language_from_header || I18n.locale.to_s
  end

  def language_from_edge_tree; end

  def language_from_header
    HttpAcceptLanguage::Parser
      .new(request.headers['HTTP_ACCEPT_LANGUAGE'])
      .compatible_language_from(I18n.available_locales)
  end

  def language_from_r # rubocop:disable Metrics/AbcSize
    resource = LinkedRails.resource_from_iri(path_to_url(params[:redirect_url])) if params[:redirect_url].present?
    return if resource.nil? || !resource.is_a?(Edge) || resource.ancestor(:forum).nil?

    language = resource.ancestor(:forum).language
    I18n.available_locales.include?(language) ? language : :en
  end

  def language_from_root
    ActsAsTenant.current_tenant&.language
  end
end
