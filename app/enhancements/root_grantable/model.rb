# frozen_string_literal: true

module RootGrantable
  module Model
    extend ActiveSupport::Concern

    included do
      accepts_nested_attributes_for :grants, reject_if: :all_blank, allow_destroy: true

      with_collection :grants
    end
  end
end
