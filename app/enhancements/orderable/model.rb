# frozen_string_literal: true

module Orderable
  module Model
    extend ActiveSupport::Concern

    included do
      self.default_sortings = [{key: NS.argu[:order], direction: :asc}]

      before_create :set_order, unless: :acts_as_list?

      property(:order, :integer, NS.argu[:order]) if self < Edge
    end

    private

    def acts_as_list?
      self.class.method_defined?(:acts_as_list_class)
    end

    def max_order
      return order_scope.maximum(:order) unless is_a?(Edge)

      order_scope.joins(:properties).where(properties: {predicate: NS.argu[:order]}).maximum('properties.integer')
    end

    def order_scope
      parent&.send(class_name) || self.class.all
    end

    def set_order
      self.order ||= (max_order || 0) + 1
    end

    class_methods do
      def sort_options(collection)
        [NS.argu[:order]] + super
      end
    end
  end
end
