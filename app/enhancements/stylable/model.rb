# frozen_string_literal: true

module Stylable
  module Model
    extend ActiveSupport::Concern

    included do
      property :accent_color, :string, NS::ARGU[:accentColor], default: '#FFFFFF'
      property :accent_background_color, :string, NS::ARGU[:accentBackgroundColor], default: '#475668'
      property :base_color, :string, NS::ARGU[:baseColor], default: '#475668'
      property :navbar_background, :string, NS::ARGU[:navbarBackground], default: '#475668'

      validates :accent_color, css_hex_color: true
      validates :accent_background_color, css_hex_color: true
      validates :base_color, css_hex_color: true

      def navbar_color
        accent_color
      end
    end
  end
end
