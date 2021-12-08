# frozen_string_literal: true

module Argumentable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :pro_arguments, predicate: NS.argu[:proArguments]
      with_collection :con_arguments, predicate: NS.argu[:conArguments]
      has_one :argument_columns,
              predicate: NS.argu[:argumentColumns],
              unless: method(:export_scope?)
      attribute :invert_arguments,
                predicate: NS.argu[:invertArguments],
                unless: method(:export_scope?)

      count_attribute :pro_arguments
      count_attribute :con_arguments
    end
  end
end
