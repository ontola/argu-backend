# frozen_string_literal: true

class Manifest < VirtualResource
  ICON_FORMATS = {
    'apple-touch-icon' => %w[114x114 120x120 144x144 152x152 180x180 57x57 60x60 72x72 76x76],
    favicon: %w[160x160 16x16 192x192 32x32 96x96],
    mstile: %w[144x144 150x150 310x310 70x70]
  }.freeze

  attr_accessor :page
  delegate :description, to: :page

  def background_color
    '#eef0f2'
  end

  def cache_resource?
    true
  end

  def dir
    :rtl
  end

  def display
    :standalone
  end

  def icons
    ICON_FORMATS.map { |name, sizes| sizes.map { |size| icon(name, size) } }.flatten
  end

  def id; end

  def lang
    page.locale
  end

  def name
    page.display_name
  end
  alias short_name name

  def ontola
    {
      secondary_main: page.accent_background_color,
      secondary_text: page.accent_color,
      css_class: page.template,
      primary_main: page.navbar_background,
      primary_text: page.navbar_color,
      template: page.template,
      template_options: template_options
    }
  end

  def serviceworker
    {
      src: "#{manifest_scope}/sw.js?manifestLocation=#{Rack::Utils.escape("#{manifest_scope}/manifest.json")}",
      scope: manifest_scope
    }
  end

  def manifest_scope
    @manifest_scope ||= "https://#{page.iri_prefix}"
  end
  alias start_url manifest_scope

  def theme_color
    page.navbar_background
  end

  private

  def icon(name, size)
    {
      src: URI(ActionController::Base.helpers.asset_path("favicons/#{page.template}/#{name}-#{size}.png")).path,
      sizes: size,
      type: 'image/png'
    }
  end

  def template_options
    JSON.parse(page.template_options).to_query
  end
end