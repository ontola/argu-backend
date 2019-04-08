# frozen_string_literal: true

module Distributable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(
        distributions_attributes: Pundit.policy(context, Distribution.new(parent: record)).permitted_attributes,
      )
      attributes
    end
  end
end
