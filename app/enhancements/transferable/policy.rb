# frozen_string_literal: true

module Transferable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[transfer_type transfer_to]
    end

    def transfer?
      return false unless administrator? || staff?
      return forbid_wrong_tier unless feature_enabled?(:transfer_content)

      true
    end
  end
end
