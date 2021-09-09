# frozen_string_literal: true

module ActivePublishable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[is_draft]
      permit_nested_attributes %i[argu_publication]
    end

    def publish?
      return true if !record.argu_publication&.publish_time_lapsed? && update?

      forbid_with_status(NS.ontola[:ExpiredActionStatus])
    end
  end
end
