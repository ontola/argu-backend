# frozen_string_literal: true

class ManifestsController < ApplicationController
  ICON_FORMATS = {
    'apple-touch-icon' => %w[114x114 120x120 144x144 152x152 180x180 57x57 60x60 72x72 76x76],
    favicon: %w[160x160 16x16 192x192 32x32 96x96],
    mstile: %w[144x144 150x150 310x310 70x70]
  }.freeze

  def show
    render json: manifest
  end

  private

  def icons
    ICON_FORMATS.map { |name, sizes| sizes.map { |size| icon(name, size) } }.flatten
  end

  def icon(name, size)
    {
      src: URI(ActionController::Base.helpers.asset_path("favicons/#{tree_root.template}/#{name}-#{size}.png")).path,
      sizes: size,
      type: 'image/png'
    }
  end

  def manifest # rubocop:disable Metrics/AbcSize
    {
      background_color: '#eef0f2',
      description: tree_root.description,
      dir: :rtl,
      display: :standalone,
      icons: icons,
      lang: tree_root.locale,
      name: tree_root.display_name,
      ontola: {
        secondary_main: tree_root.accent_background_color,
        secondary_text: tree_root.accent_color,
        css_class: tree_root.template,
        primary_main: tree_root.navbar_background,
        primary_text: tree_root.navbar_color,
        template: tree_root.template,
        template_options: JSON.parse(tree_root.template_options).to_query
      },
      scope: scope,
      serviceworker: {
        src: "#{scope}/sw.js?manifestLocation=#{Rack::Utils.escape("#{scope}/manifest.json")}",
        scope: scope
      },
      short_name: tree_root.display_name,
      start_url: scope,
      theme_color: tree_root.navbar_background
    }
  end

  def scope
    @scope ||= "https://#{tree_root.iri_prefix}"
  end
end
