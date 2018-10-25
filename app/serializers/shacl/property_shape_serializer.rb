# frozen_string_literal: true

module SHACL
  class PropertyShapeSerializer < ShapeSerializer
    attribute :datatype, predicate: NS::SH[:datatype]
    attribute :default_value, predicate: NS::SH[:defaultValue]
    attribute :description, predicate: NS::SH[:description]
    attribute :group, predicate: NS::SH[:group]
    attribute :max_count, predicate: NS::SH[:maxCount]
    attribute :min_count, predicate: NS::SH[:minCount]
    attribute :max_length, predicate: NS::SH[:maxLength]
    attribute :min_length, predicate: NS::SH[:minLength]
    attribute :name, predicate: NS::SH[:name]
    attribute :node, predicate: NS::SH[:node]
    attribute :node_kind, predicate: NS::SH[:nodeKind]
    attribute :order, predicate: NS::SH[:order]
    attribute :pattern, predicate: NS::SH[:pattern]
    attribute :sh_class, predicate: NS::SH[:class]
    attribute :sh_in, predicate: NS::SH[:in]

    has_many :path, predicate: NS::SH[:path]

    def type
      NS::SH[:PropertyShape]
    end

    def path
      object.path.respond_to?(:each) ? object.path : [Resource.for(object.path)]
    end

    def sh_in
      options = object.sh_in
      return if options.blank?
      options = options.call(object) if options.respond_to?(:call)
      options.is_a?(Array) ? RDF::List[*options] : options
    end
  end
end
