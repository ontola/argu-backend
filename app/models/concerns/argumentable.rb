# frozen_string_literal: true

module Argumentable
  extend ActiveSupport::Concern

  included do
    with_collection :pro_arguments, pagination: true
    with_collection :con_arguments, pagination: true
    accepts_nested_attributes_for :pro_arguments
    accepts_nested_attributes_for :con_arguments

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

  module Actions
    extend ActiveSupport::Concern

    included do
      define_default_create_action :pro_argument, image: 'fa-plus'
      define_default_create_action :con_argument, image: 'fa-plus'
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :pro_arguments, predicate: NS::ARGU[:proArguments]
      with_collection :con_arguments, predicate: NS::ARGU[:conArguments]
    end
  end
end
