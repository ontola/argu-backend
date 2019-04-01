# frozen_string_literal: true

module Stylable
  module Model
    extend ActiveSupport::Concern

    included do
      property :accent_color, :string, NS::ARGU[:accentColor], default: 'white'
      property :accent_background_color, :string, NS::ARGU[:accentBackgroundColor], default: 'rgb(71, 86, 104)'
      property :base_color, :string, NS::ARGU[:baseColor], default: 'rgb(71, 86, 104)'
      property :navbar_background, :string, NS::ARGU[:navbarBackground], default: 'rgb(71, 86, 104)'

      def navbar_color
        accent_color
      end
    end
  end
end
