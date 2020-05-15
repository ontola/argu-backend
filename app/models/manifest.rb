# frozen_string_literal: true

class Manifest < VirtualResource
  ICON_FORMATS = {
    'apple-touch-icon' => %w[114x114 120x120 144x144 152x152 180x180 57x57 60x60 72x72 76x76],
    favicon: %w[160x160 16x16 192x192 32x32 96x96],
    mstile: %w[144x144 150x150 310x310 70x70]
  }.freeze

  include Cacheable

  attr_accessor :page

  alias_attribute :root, :page

  def background_color
    '#eef0f2'
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

  def ontola # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    {
      allowed_external_sources: page.allowed_external_sources,
      secondary_main: page.accent_background_color,
      secondary_text: page.accent_color,
      css_class: page.template,
      matomo_hostname: page.matomo_host || ENV['MATOMO_HOST'],
      matomo_site_id: page.matomo_site_id,
      primary_main: page.navbar_background,
      primary_text: page.navbar_color,
      styled_headers: page.styled_headers,
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
  alias scope manifest_scope

  def start_url
    @start_url ||= "#{manifest_scope}/"
  end

  def theme_color
    page.navbar_background
  end

  def write_to_cache(cache = Argu::Cache.new)
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      cache.write(self, :attributes, :json, key_transform: :underscore)
    end
  end

  private

  def icon(name, size)
    {
      src: URI(
        ActionController::Base.helpers.asset_path(
          "assets/favicons/#{page.template}/#{name}-#{size}.png",
          skip_pipeline: true
        )
      ).path,
      sizes: size,
      type: 'image/png'
    }
  end

  def template_options
    JSON.parse(page.template_options).to_query
  end
end
