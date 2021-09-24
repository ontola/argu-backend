# frozen_string_literal: true

module Transferable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[transfer_to], grant_sets: %i[staff]
    end

    def transfer?
      staff?
    end
  end
end
