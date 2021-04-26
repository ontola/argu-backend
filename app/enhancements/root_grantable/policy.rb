# frozen_string_literal: true

module RootGrantable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[grants]
    end
  end
end
