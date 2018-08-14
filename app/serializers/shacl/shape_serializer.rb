# frozen_string_literal: true

module SHACL
  class ShapeSerializer < BaseSerializer
    attribute :deactivated, predicate: NS::SH[:deactivated]
    attribute :label, predicate: NS::RDFS[:label]
    attribute :message, predicate: NS::SH[:message]
    attribute :severity, predicate: NS::SH[:severity]
    attribute :sparql, predicate: NS::SH[:sparql]
    attribute :target, predicate: NS::SH[:target]
    attribute :target_class, predicate: NS::SH[:targetClass]
    attribute :target_node, predicate: NS::SH[:targetNode]
    attribute :target_objects_of, predicate: NS::SH[:targetObjectsOf]
    attribute :target_subjects_of, predicate: NS::SH[:targetSubjectsOf]

    has_many :referred_shapes, predicate: NS::ARGU[:referredShapes]

    def referred_shapes
      object.referred_shapes&.map do |shape|
        if shape.is_a?(Class) && shape < FormsBase
          shape.new(user_context, shape.model_class.new).shape
        else
          shape
        end
      end
    end

    def type
      NS::SH[:Shape]
    end
  end
end
