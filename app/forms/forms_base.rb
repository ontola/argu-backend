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
      property: properties,
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
    return true if _property_groups[attr.model_attribute]

    permitted_attributes.find do |p_a|
      if p_a.is_a?(Hash)
        p_a.keys.include?("#{attr.model_attribute}_attributes".to_sym)
      else
        p_a == attr.model_attribute
      end
    end
  end

  def properties
    @properties ||= self.class.property_shapes.select(&method(:permit_attribute))
  end

  def target_class
    target.is_a?(Class) ? target : target.class
  end

  class << self
    def inherited(target)
      target._fields = {}
      target._property_groups = {}
    end

    def property_shapes
      @property_shapes ||=
        _fields
          .map { |k, attr| property_shape(k, attr || {}) }
          .compact
    end

    private

    def ar_attr_to_datatype(attr)
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

    def attribute_for_key(key)
      return serializer_attributes[key] if serializer_attributes[key]

      k_v = serializer_reflections.find { |_k, v| (v[:options][:association] || v.name) == key }
      k_v[1] if k_v
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
      arr.each do |field|
        raise "Resource field '#{field}' defined twice" if _fields[field].present?
        _fields[field.try(:to_sym)] = {
          order: _fields.keys.length,
          group: group_iri
        }
      end
    end

    def literal_property(attr, pred, instance_props)
      enum = model_class.defined_enums[attr.name.to_s]&.keys
      datatype = attr.dig(:options, :datatype) || (enum ? NS::XSD[:string] : ar_attr_to_datatype(attr))
      SHACL::PropertyShape.new(
        datatype: datatype,
        max_count: 1,
        description: description_for_attr(attr),
        group: instance_props[:group],
        model_attribute: (model_class.attribute_alias(attr.name) || attr.name).to_sym,
        name: name_for_attr(attr.name),
        order: instance_props[:order],
        path: pred,
        sh_in: enum && RDF::List(enum)
      )
    end

    def model_class
      @model_class ||= name.sub(/Form$/, '').safe_constantize
    end

    def name_for_attr(attr_key)
      I18n.t("#{model_class.model_name.plural}.form.#{attr_key}_heading",
             default: I18n.t("formtastic.labels.#{attr_key}", default: nil))
    end

    def node_property(attr, pred, instance_props)
      name = attr.dig(:options, :association) || attr.name
      collection = model_class.try(:collections)&.find { |c| c[:name] == name }
      klass_name = model_class.try(:reflections).try(:[], name.to_s)&.class_name || name.to_s.classify

      max_count = collection || attr.is_a?(ActiveModel::Serializer::HasManyReflection) ? nil : 1

      SHACL::PropertyShape.new(
        description: description_for_attr(attr),
        group: instance_props[:group],
        max_count: max_count,
        model_attribute: (model_class.attribute_alias(name) || name).to_sym,
        name: name_for_attr(name),
        order: instance_props[:order],
        path: pred,
        sh_class: klass_name.constantize.iri,
        referred_shapes: ["#{klass_name}Form".safe_constantize]
      )
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

    def property_shape(attr_key, instance_props = {})
      attr = attribute_for_key(attr_key)
      pred = attr&.dig(:options, :predicate)
      return if pred.blank?

      if attr.is_a?(ActiveModel::Serializer::Attribute)
        literal_property(attr, pred, instance_props)
      else
        node_property(attr, pred, instance_props)
      end
    end

    def serializer_class
      @serializer_class ||= model_class.serializer_class!
    end

    def serializer_attributes
      serializer_class._attributes_data
    end

    def serializer_reflections
      serializer_class._reflections
    end
  end
end
