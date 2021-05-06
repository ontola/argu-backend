# frozen_string_literal: true

module RootGrantable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[grants]
    end

    def show?
      return true if new_record? && record.parent.is_a?(Page)

      super
    end
  end
end
