# frozen_string_literal: true

module Argumentable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :pro_arguments, default_sortings: [{key: NS::ARGU[:votesProCount], direction: :desc}]
      with_collection :con_arguments, default_sortings: [{key: NS::ARGU[:votesProCount], direction: :desc}]
      accepts_nested_attributes_for :pro_arguments
      accepts_nested_attributes_for :con_arguments
      attribute :invert_arguments, :boolean

      def invert_arguments
        false
      end

      def invert_arguments=(invert)
        return if invert == '0'
        Motion.transaction do
          arguments.each do |a|
            a.update_attributes pro: !a.pro
          end
        end
      end
    end

    module ClassMethods
      def show_includes
        super + [
          con_argument_collection: inc_shallow_collection,
          pro_argument_collection: inc_shallow_collection
        ]
      end
    end
  end
end
