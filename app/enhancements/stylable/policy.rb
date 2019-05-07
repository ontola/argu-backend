# frozen_string_literal: true

module Stylable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(%i[navbar_color navbar_background accent_color accent_background_color]) unless new_record?
      attributes
    end
  end
end
