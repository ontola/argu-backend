# frozen_string_literal: true

module Argumentable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(:invert_arguments)
      attributes.append(
        pro_arguments_attributes: arguments_attributes,
        con_arguments_attributes: arguments_attributes
      )
      attributes
    end

    private

    def arguments_attributes
      Pundit.policy(context, Argument.new(parent: record)).permitted_attributes
    end
  end
end
