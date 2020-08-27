# frozen_string_literal: true

module Stylable
  module Model
    extend ActiveSupport::Concern

    included do
      property :primary_color, :string, NS::ARGU[:primaryColor], default: '#475668'
      property :secondary_color, :string, NS::ARGU[:secondaryColor], default: '#d96833'
      property :header_background,
               :integer,
               NS::ARGU[:headerBackground],
               default: 0,
               enum: {background_primary: 0, background_secondary: 1, background_white: 2}
      property :header_text,
               :integer,
               NS::ARGU[:headerText],
               default: 2,
               enum: {text_auto: 2, text_primary: 0, text_secondary: 1, text_white: 3, text_black: 4}

      validates :secondary_color, css_hex_color: true
      validates :primary_color, css_hex_color: true
    end
  end
end
