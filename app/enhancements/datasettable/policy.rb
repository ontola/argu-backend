# frozen_string_literal: true

module Datasettable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(
        datasets_attributes: Pundit.policy(context, Dataset.new(parent: record)).permitted_attributes,
      )
      attributes
    end
  end
end
