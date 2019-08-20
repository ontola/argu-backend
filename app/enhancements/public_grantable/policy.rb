# frozen_string_literal: true

module PublicGrantable
  module Policy
    extend ActiveSupport::Concern

    def has_grant?(action)
      has_grant = super
      return has_grant if has_grant || action != :show || record.persisted?

      record.default_public_grant && record.default_public_grant != :none
    end

    def permitted_attribute_names
      super + %i[public_grant]
    end
  end
end
