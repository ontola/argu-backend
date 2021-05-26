# frozen_string_literal: true

module Menus
  class Item < LinkedRails::Menus::Item
    attr_writer :image, :description

    %i[image description].each do |method|
      callable_variable(method, instance: :parent)
    end

    def href
      @href ||= super.is_a?(String) ? RDF::URI(super) : super
    end
  end
end
