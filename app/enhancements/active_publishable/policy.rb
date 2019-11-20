# frozen_string_literal: true

module ActivePublishable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(argu_publication_attributes: %i[id draft published_at])
      attributes
    end
  end
end
