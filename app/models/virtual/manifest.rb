# frozen_string_literal: true

class Manifest < VirtualResource # rubocop:disable Metrics/ClassLength
  ICON_FORMATS = {
    'apple-touch-icon' => %w[114x114 120x120 144x144 152x152 180x180 57x57 60x60 72x72 76x76],
    favicon: %w[160x160 16x16 192x192 32x32 512x512 96x96],
    mstile: %w[144x144 150x150 310x310 70x70]
  }.freeze

  include Cacheable

  attr_accessor :page

  alias_attribute :root, :page

  def anonymous_iri?
    false
  end

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
      css_class: page.template,
      header_background: page.header_background.sub('background_', ''),
      header_text: page.header_text.sub('text_', ''),
      preconnect: [
        Rails.application.config.aws_url
      ].compact,
      preload: preload_iris,
      primary_color: page.primary_color,
      secondary_color: page.secondary_color,
      styled_headers: page.styled_headers,
      theme: page.template,
      theme_options: template_options,
      tracking: tracking,
      website_iri: page.iri
    }
  end

  def preload_iris # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      LinkedRails.iri,
      LinkedRails.iri(path: 'ns/core').to_s,
      LinkedRails.iri(path: 'c_a').to_s,
      LinkedRails.iri(path: 'banners').to_s,
      LinkedRails.iri(path: 'search').to_s,
      LinkedRails.iri(path: 'forms/linked_rails/auth/sessions').to_s,
      LinkedRails.iri(path: 'forms/linked_rails/auth/access_tokens').to_s,
      LinkedRails.iri(path: 'forms/users/registrations').to_s,
      LinkedRails.iri(path: 'menus').to_s
    ]
  end

  def serviceworker
    {
      src: "#{page.iri}/sw.js?manifestLocation=#{Rack::Utils.escape("#{page.iri}/manifest.json")}",
      scope: manifest_scope
    }
  end

  def tracking # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    trackers = []

    if page.google_uac
      trackers << {
        type: 'GUA',
        container_id: page.google_uac
      }
    end
    if page.google_tag_manager
      trackers << {
        type: 'GTM',
        container_id: page.google_tag_manager
      }
    end
    if page.matomo_site_id
      trackers << {
        type: 'Matomo',
        host: page.matomo_host || ENV['MATOMO_HOST'],
        container_id: page.matomo_site_id
      }
    end
    if page.piwik_pro_site_id
      trackers << {
        type: 'PiwikPro',
        host: page.piwik_pro_host,
        container_id: page.piwik_pro_site_id
      }
    end

    trackers
  end

  def manifest_scope
    @manifest_scope ||= page.iri.path || '/'
  end
  alias scope manifest_scope

  def start_url
    @start_url ||= manifest_scope == '/' ? manifest_scope : "#{manifest_scope}/"
  end

  def theme_color
    page.primary_color
  end

  private

  def icon(name, size)
    props = {
      src: icon_src(name, size),
      sizes: size,
      type: 'image/png'
    }
    props[:purpose] = 'any maskable' if size == '192x192' && name == 'favicon'
    props
  end

  def icon_src(name, size)
    URI(
      ActionController::Base.helpers.asset_path(
        "assets/favicons/#{page.template}/#{name}-#{size}.png",
        skip_pipeline: true
      )
    ).path
  end

  def template_options
    JSON.parse(page.template_options).to_query
  end
end
