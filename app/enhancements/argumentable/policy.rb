# frozen_string_literal: true

module Argumentable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(:invert_arguments)
      attributes.append(
        pro_arguments_attributes: arguments_attributes(ProArgument),
        con_arguments_attributes: arguments_attributes(ConArgument)
      )
      attributes
    end

    private

    def arguments_attributes(klass)
      Pundit.policy(context, klass.new(parent: record)).permitted_attributes
    end
  end
end
