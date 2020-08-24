# frozen_string_literal: true

module Stylable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :secondary_color, predicate: NS::ARGU[:secondaryColor]
      attribute :primary_color, predicate: NS::ARGU[:primaryColor]
      enum :header_background, predicate: NS::ARGU[:headerBackground]
      enum :header_text, predicate: NS::ARGU[:headerText]
    end
  end
end
