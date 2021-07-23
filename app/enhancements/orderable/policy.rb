# frozen_string_literal: true

module Orderable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[order]
    end
  end
end
