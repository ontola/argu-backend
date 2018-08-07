# frozen_string_literal: true

module SHACL
  class PropertyShape < Shape
    class << self
      def iri
        NS::SH[:PropertyShape]
      end

      def validations(*validations)
        validations.each do |key, klass, option_key|
          attr_writer key

          define_method key do
            instance_variable_get(:"@#{key}") || validator_option(klass, option_key)
          end
        end
      end
    end

    # Custom attributes
    attr_accessor :model_attribute, :form

    # SHACL attributes
    attr_accessor :sh_class,
                  :datatype,
                  :default_value,
                  :description,
                  :group,
                  :model_class,
                  :name,
                  :node,
                  :node_kind,
                  :node_shape,
                  :max_count,
                  :order,
                  :path,
                  :validators

    validations [:min_count, ActiveRecord::Validations::PresenceValidator, :min_count],
                [:min_length, ActiveRecord::Validations::LengthValidator, :minimum],
                [:max_length, ActiveRecord::Validations::LengthValidator, :maximum],
                [:sh_in, ActiveModel::Validations::InclusionValidator, :in]

    def validator_option(klass, option_key)
      option = validators&.detect { |validator| validator.is_a?(klass) }&.options.try(:[], option_key)
      option.respond_to?(:call) ? option.call(form.target) : option
    end
  end
end
