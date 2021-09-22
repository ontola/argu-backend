# frozen_string_literal: true

module Orderable
  module Model
    extend ActiveSupport::Concern

    included do
      include ActiveRecord::Acts::List::InstanceMethods

      self.default_sortings = [{key: NS.argu[:order], direction: :asc}]

      acts_as_list touch_on_update: false

      if self < Edge
        property(:position, :integer, NS.argu[:order])
        scope :in_list,
              lambda {
                property_join(:position)
                  .where("#{connection.quote_string(quoted_position_column_with_table_name)} IS NOT NULL")
              }

        def quoted_position_column_with_table_name
          '"position_filter"."value"'
        end

        def acts_as_list_list
          super.property_join(:position)
        end

        def scope_condition
          return {parent: parent} if try(:parent).present?

          {}
        end

        class << self
          def decrement_all
            Property.where(edge: all, predicate: NS.argu[:order]).find_each do |property|
              property.update(integer: property.integer - 1)
            end
          end

          def increment_all
            Property.where(edge: all, predicate: NS.argu[:order]).find_each do |property|
              property.update(integer: property.integer + 1)
            end
          end

          def quoted_position_column_with_table_name
            '"position_filter"."value"'
          end
        end
      end
    end

    private

    class_methods do
      def sort_options(collection)
        [NS.argu[:order]] + super
      end
    end
  end
end
