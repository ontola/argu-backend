# frozen_string_literal: true

module Argumentable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[invert_arguments]
      permit_nested_attributes %i[pro_arguments con_arguments]
    end
  end
end
