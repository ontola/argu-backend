# frozen_string_literal: true

module ActivePublishable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(argu_publication_attributes: argu_publication_attributes)
      attributes
    end

    private

    def argu_publication_attributes
      argu_publication_attributes = %i[id draft]
      argu_publication_attributes.append(:published_at) if moderator? || administrator? || staff?
      argu_publication_attributes
    end
  end
end
