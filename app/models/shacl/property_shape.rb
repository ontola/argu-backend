# frozen_string_literal: true

module SHACL
  class PropertyShape < Shape
    # Custom attributes
    attr_accessor :model_attribute

    # SHACL attributes
    attr_accessor :sh_class,
                  :datatype,
                  :default_value,
                  :description,
                  :group,
                  :name,
                  :node,
                  :node_kind,
                  :order,
                  :path,
                  :sh_in,
                  :max_count

    def self.iri
      NS::SH[:PropertyShape]
    end
  end
end
