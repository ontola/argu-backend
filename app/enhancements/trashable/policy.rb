# frozen_string_literal: true

module Trashable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(trash_activity_attributes: :comment)
      attributes.append(untrash_activity_attributes: :comment)
      attributes
    end
  end
end
