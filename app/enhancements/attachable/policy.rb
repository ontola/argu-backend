# frozen_string_literal: true

module Attachable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(
        attachments_attributes: Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
      )
      attributes
    end
  end
end
