# frozen_string_literal: true

module Distributable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :distributions
      accepts_nested_attributes_for :distributions
    end

    module ClassMethods
      def show_includes
        super + [distribution_collection: inc_shallow_collection]
      end
    end
  end
end
