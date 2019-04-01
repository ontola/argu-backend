# frozen_string_literal: true

module Stylable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :accent_color, predicate: NS::ARGU[:accentColor]
      attribute :accent_background_color, predicate: NS::ARGU[:accentBackgroundColor]
      attribute :base_color, predicate: NS::ARGU[:baseColor]
      attribute :navbar_background, predicate: NS::ARGU[:navbarBackground]
      attribute :navbar_color, predicate: NS::ARGU[:navbarColor]
    end
  end
end
