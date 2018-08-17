# frozen_string_literal: true

module Argumentable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :pro_arguments, predicate: NS::ARGU[:proArguments]
      with_collection :con_arguments, predicate: NS::ARGU[:conArguments]
      attribute :invert_arguments, predicate: NS::ARGU[:invertArguments]

      count_attribute :arguments_pro
      count_attribute :arguments_con
    end
  end
end
