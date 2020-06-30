# frozen_string_literal: true

module ActivePublishable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[is_draft]
      permit_nested_attributes %i[argu_publication]
    end
  end
end
