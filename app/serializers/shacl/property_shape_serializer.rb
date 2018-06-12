# frozen_string_literal: true

module SHACL
  class PropertyShapeSerializer < ShapeSerializer
    attribute :datatype, predicate: NS::SH[:datatype]
    attribute :default_value, predicate: NS::SH[:defaultValue]
    attribute :description, predicate: NS::SH[:description]
    attribute :group, predicate: NS::SH[:group]
    attribute :name, predicate: NS::SH[:name]
    attribute :node, predicate: NS::SH[:node]
    attribute :node_kind, predicate: NS::SH[:nodeKind]
    attribute :order, predicate: NS::SH[:order]
    attribute :sh_class, predicate: NS::SH[:class]
    attribute :sh_in, predicate: NS::SH[:in]
    attribute :max_count, predicate: NS::SH[:maxCount]

    has_many :path, predicate: NS::SH[:path]

    def type
      NS::SH[:PropertyShape]
    end

    def path
      object.path.respond_to?(:each) ? object.path : [Resource.for(object.path)]
    end
  end
end
