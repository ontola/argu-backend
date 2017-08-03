# frozen_string_literal: true

module Argu
  class StatefulServerRenderer < React::ServerRendering::BundleRenderer
    def before_render(_component_name, _props, _prerender_options)
      super + "I18n.defaultLocale = '#{Rails.configuration.i18n.default_locale}'; "\
              "I18n.fallbacks = true; I18n.locale = '#{I18n.locale}';"
    end
  end
end
