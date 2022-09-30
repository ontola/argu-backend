# frozen_string_literal: true

class Manifest < LinkedRails::Manifest # rubocop:disable Metrics/ClassLength
  ICON_FORMATS = {
    'apple-touch-icon' => %w[114x114 120x120 144x144 152x152 180x180 57x57 60x60 72x72 76x76],
    favicon: %w[160x160 16x16 192x192 32x32 512x512 96x96],
    mstile: %w[144x144 150x150 310x310 70x70]
  }.freeze

  attr_accessor :page

  alias_attribute :root, :page

  def anonymous_iri?
    false
  end

  def id; end

  def iri
    "#{page.iri}/manifest.json"
  end

  def save
    ActsAsTenant.with_tenant(page) do
      super
    end
  end

  def web_manifest
    ActsAsTenant.with_tenant(page) do
      super
    end
  end

  private

  def allowed_external_sources
    page.allowed_external_sources
  end

  def background_color
    '#eef0f2'
  end

  def csp_entries # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    page_specific_entries = {
      connectSrc: [
        matomo_host,
        storage_endpoint
      ].compact,
      scriptSrc: [
        matomo_cdn
      ].compact,
      imgSrc: []
    }

    if page.google_uac
      page_specific_entries.scriptSrc << 'https://www.google-analytics.com'
      page_specific_entries.connectSrc << 'https://www.google-analytics.com'
      page_specific_entries.imgSrc << 'https://www.google-analytics.com'
    end

    if page.google_tag_manager
      page_specific_entries.scriptSrc << 'https://*.googletagmanager.com'
      page_specific_entries.connectSrc += %w[
        https://*.google-analytics.com
        https://*.analytics.google.com
        https://*.googletagmanager.com
      ]
      page_specific_entries.imgSrc += %w[
        https://*.google-analytics.com
        https://*.googletagmanager.com
      ]
    end

    super.deep_merge(page_specific_entries)
  end

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

  def icons
    ICON_FORMATS.map { |name, sizes| sizes.map { |size| icon(name, size) } }.flatten
  end

  def lang
    page.locale
  end

  def app_name
    page.display_name
  end

  def header_background
    page.header_background.sub('background_', '')
  end

  def header_text
    page.header_text.sub('text_', '')
  end

  def matomo_cdn
    page.matomo_cdn || ENV['MATOMO_CDN'] || ENV['MATOMO_HOST']
  end

  def matomo_host
    page.matomo_host || ENV['MATOMO_HOST']
  end

  def preconnect
    [
      Rails.application.config.aws_url
    ].compact
  end

  def storage_endpoint
    active_storage = Rails.application.config.active_storage
    config = active_storage.dig(:service_configurations, active_storage[:service].to_s)

    if config['service'] == 'S3'
      ActiveStorage::Blob.service.bucket.url
    else
      config['endpoint']
    end
  end

  def styled_headers
    page.styled_headers
  end

  def scope
    page.iri.path || '/'
  end

  def site_theme_color
    page.primary_color
  end

  def site_secondary_color
    page.secondary_color
  end

  def theme
    page.template
  end

  def theme_options
    JSON.parse(page.template_options)
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
        host: matomo_host,
        cdn: matomo_cdn,
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
end
