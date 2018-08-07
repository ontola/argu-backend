# frozen_string_literal: true

class FormsBase
  class_attribute :_fields, :_property_groups
  attr_accessor :user_context, :target

  def initialize(user_context, target)
    @user_context = user_context
    @target = target
  end

  def iri
    iri = target.iri.dup
    iri.fragment = self.class.name
    iri
  end

  def shape
    klass =
      if target.is_a?(Class)
        target
      elsif target.new_record?
        target.class
      end
    SHACL::NodeShape.new(
      iri:  iri,
      target_class: klass&.iri,
      target_node: klass ? nil : target.iri,
      property: permitted_properties,
      referred_shapes: _property_groups.values
    )
  end

  private

  def permitted_attributes
    @permitted_attributes ||=
      Pundit
        .policy(user_context, target)
        .permitted_attributes
  end

  def permit_attribute(attr)
    return true if _property_groups[attr[:model_attribute]]
    permitted_attributes.find do |p_a|
      if p_a.is_a?(Hash)
        p_a.keys.include?("#{attr[:model_attribute]}_attributes".to_sym)
      else
        p_a == attr[:model_attribute]
      end
    end
  end

  def permitted_properties
    @permitted_properties ||=
      self.class.property_shapes_attrs.select(&method(:permit_attribute)).map(&method(:property_shape))
  end

  def property_shape(attrs)
    SHACL::PropertyShape.new(attrs.merge(form: self))
  end

  def target_class
    target.is_a?(Class) ? target : target.class
  end

  class << self
    def inherited(target)
      target._fields = {}
      target._property_groups = {}
    end

    def property_shapes_attrs
      @property_shapes_attrs ||=
        _fields
          .map { |k, attr| property_shape_attrs(k, attr || {}) }
          .compact
    end

    private

    def attr_to_datatype(attr)
      return nil if method_defined?(attr.name)

      name = attr.name.to_s
      case model_class.attribute_types[name].type
      when :string, :text
        NS::XSD[:string]
      when :integer
        NS::XSD[:integer]
      when :datetime
        NS::XSD[:dateTime]
      when :boolean
        NS::XSD[:boolean]
      when :decimal
        decimal_data_type(name)
      when :file
        NS::LL[:blob]
      else
        NS::XSD[:string] if model_class.defined_enums.key?(name)
      end
    end

    def decimal_data_type(name)
      case model_class.columns_hash[name].precision
      when 64
        NS::XSD[:long]
      when 32
        NS::XSD[:int]
      when 16
        NS::XSD[:short]
      when 8
        NS::XSD[:byte]
      else
        NS::XSD[:decimal]
      end
    end

    # The placeholder of the property.
    # Translations are currently all-over-the-place, so we need some nesting, though
    # doesn't include a generic fallback mechanism yet.
    def description_for_attr(attr)
      attr_key = model_class.attribute_alias(attr.name) || attr.name
      model_name = model_class.model_name.i18n_key
      I18n.t("formtastic.placeholders.#{model_name}.#{attr_key}",
             default: I18n.t(
               "formtastic.placeholders.#{attr_key}",
               default: I18n.t(
                 "formtastic.hints.#{model_name}.#{attr_key}",
                 default: I18n.t(
                   "formtastic.hints.#{attr_key}",
                   default: nil
                 )
               )
             ))
    end

    def fields(arr, group_iri = nil)
      arr.each { |f| field(f, group: group_iri) }
    end

    def field(key, opts = {})
      raise "Resource field '#{field}' defined twice" if _fields[key].present?
      opts[:order] = _fields.keys.length
      _fields[key.try(:to_sym)] = opts
    end

    def literal_property_attrs(attr, attrs)
      enum = model_enums[attr.name.to_s]
      attrs[:datatype] = attr.dig(:options, :datatype) || (enum ? NS::XSD[:string] : attr_to_datatype(attr))
      attrs[:max_count] = 1
      attrs[:sh_in] = enum && RDF::List(enum)
      attrs
    end

    def model_attribute(attr)
      (model_class.attribute_alias(attr) || attr).to_sym
    end

    def model_class
      @model_class ||= name.sub(/Form$/, '').safe_constantize
    end

    def model_enums
      model_class.try(:defined_enums) || {}
    end

    def name_for_attr(attr_key)
      I18n.t("#{model_class.model_name.plural}.form.#{attr_key}_heading",
             default: I18n.t("formtastic.labels.#{attr_key}", default: nil))
    end

    def node_property_attrs(attr, attrs)
      name = attr.dig(:options, :association) || attr.name
      collection = model_class.try(:collections)&.find { |c| c[:name] == name }
      klass_name = model_class.try(:reflections).try(:[], name.to_s)&.class_name || name.to_s.classify

      attrs[:description] ||= description_for_attr(attr.name)
      attrs[:name] ||= name_for_attr(attr.name)
      attrs[:max_count] ||= collection || attr.is_a?(ActiveModel::Serializer::HasManyReflection) ? nil : 1
      attrs[:sh_class] ||= klass_name.constantize.iri
      attrs[:referred_shapes] ||= ["#{klass_name}Form".safe_constantize]
      attrs
    end

    def predicate_from_serializer(serializer_attr)
      serializer_attr&.dig(:options, :predicate)
    end

    def property_group(name, opts = {})
      raise "Property group '#{name}' defined twice" if _property_groups[name].present?
      raise "Property group '#{name}' not available in fields" if _fields[name].nil?
      group = SHACL::PropertyGroup.new(
        label: opts[:label]
      )
      _fields[name][:is_group] = true
      _property_groups[name] = group
      fields opts[:properties], group.iri
    end

    def property_shape_attrs(attr_key, attrs = {})
      return if _property_groups.key?(attr_key)
      serializer_attr = serializer_attribute(attr_key)
      attrs[:path] ||= predicate_from_serializer(serializer_attr)

      attrs[:model_attribute] ||= model_attribute(attr_key)
      attrs[:validators] ||= validators(attrs[:model_attribute])
      return attrs if serializer_attr.blank?

      if serializer_attr.is_a?(ActiveModel::Serializer::Attribute)
        literal_property_attrs(serializer_attr, attrs)
      elsif serializer_attr.is_a?(ActiveModel::Serializer::Reflection)
        node_property_attrs(serializer_attr, attrs)
      end
    end

    def serializer_attribute(key)
      return serializer_attributes[key] if serializer_attributes[key]

      k_v = serializer_reflections.find { |_k, v| (v[:options][:association] || v.name) == key }
      k_v[1] if k_v
    end

    def serializer_class
      @serializer_class ||= model_class.try(:serializer_class!)
    end

    def serializer_attributes
      serializer_class&._attributes_data || {}
    end

    def serializer_reflections
      serializer_class&._reflections || {}
    end

    def validators(model_attribute)
      model_class.validators.select { |v| v.attributes.include?(model_attribute) }
    end
  end
end
