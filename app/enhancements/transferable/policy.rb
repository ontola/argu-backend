# frozen_string_literal: true

module Transferable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[transfer_type transfer_to]
    end

    def transfer?
      staff?
    end
  end
end
