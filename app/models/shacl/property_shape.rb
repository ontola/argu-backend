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
                  :group,
                  :model_class,
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
                [:pattern, ActiveModel::Validations::FormatValidator, :with],
                [:sh_in, ActiveModel::Validations::InclusionValidator, :in]

    # The placeholder of the property.
    # Translations are currently all-over-the-place, so we need some nesting, though
    # doesn't include a generic fallback mechanism yet.
    def description
      I18n.t("formtastic.placeholders.#{model_name}.#{model_attribute}",
             default: [
               :"formtastic.placeholders.#{model_attribute}",
               :"formtastic.hints.#{model_name}.#{model_attribute}",
               :"formtastic.hints.#{model_attribute}",
               ''
             ]).presence
    end

    def model_name
      @model_name ||= form.target.model_name.i18n_key
    end

    def name
      I18n.t("#{model_name}.form.#{model_attribute}_heading",
             default: I18n.t("formtastic.labels.#{model_attribute}", default: nil))
    end

    def validator_option(klass, option_key)
      option = validators&.detect { |validator| validator.is_a?(klass) }&.options.try(:[], option_key)
      option.respond_to?(:call) ? option.call(form.target) : option
    end
  end
end
