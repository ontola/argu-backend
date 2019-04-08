# frozen_string_literal: true

module Datasettable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :datasets
      accepts_nested_attributes_for :datasets
    end

    module ClassMethods
      def show_includes
        super + [dataset_collection: inc_shallow_collection]
      end
    end
  end
end
