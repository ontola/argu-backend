# frozen_string_literal: true

# Concern which gives Models the `convert` ability.
#
# Converts as many parameters and assocations as possible.
module Convertible
  extend ActiveSupport::Concern

  included do
  end

  def is_convertible?
    true
  end

  # Converts an item to another item
  # Children of models that are not whitelisted will be converted to comments
  def convert_to(klass, validate: true)
    raise ArgumentError.new("Conversion to #{klass.class_name} not allowed") unless convert_to?(klass)

    ActiveRecord::Base.transaction do
      shared_attributes =
        (klass.column_names + klass.attribute_aliases.keys)
          .reject { |n| !(attribute_names + attribute_aliases.keys).include?(n) || n == 'id' }

      new_model = klass.new Hash[shared_attributes.select { |i| attributes[i].present? }.map { |i| [i, attributes[i]] }]
      new_model.edge = edge
      until new_model.parent_classes.include?(new_model.edge.parent.owner_type.underscore.to_sym)
        new_model.edge.parent = new_model.edge.parent.parent
      end
      new_model.save!(validate: validate)

      convert_or_destroy_children(new_model)

      convertible_classes[klass.class_name.to_sym].each do |association|
        klass_association = self.class.reflect_on_association(association)
        # Just to be sure
        next unless klass_association.macro == :has_many
        send(association).each do |associated_model|
          associated_model.send("#{klass_association.foreign_key}=", new_model.id)
          associated_model.send("#{klass_association.type}=", new_model.class.name) if klass_association.type.present?
          associated_model.save!(validate: false)
        end
        send(association).clear
      end
      # Reload to make sure the Edge is no longer marked as dependent
      reload
      {old: destroy, new: new_model}
    end
  end

  def convert_or_destroy_children(new_model)
    new_model.displaced_children.each do |child|
      if new_model.is_a?(Comment) && child.owner.is_a?(Comment)
        child.owner.parent_comment = new_model
        child.owner.commentable = new_model.parent_model
        child.parent = new_model.parent_edge
        child.owner.save!(validate: false)
      elsif child.owner.convert_to?(Comment) && Comment.parent_classes.include?(class_name.singularize.to_sym)
        child.owner.convert_to(Comment, validate: false)
      else
        child.destroy!
      end
    end
  end

  def convert_to?(klass)
    return false unless respond_to?(:convertible_classes)
    convertible_classes.include?(klass.class_name.to_sym)
  end

  # Find children that don't allow the new class as parent
  # @return [Array<Edge>]
  def displaced_children
    edge.children.reject { |edge| edge.owner.parent_classes.include?(class_name.singularize.to_sym) }
  end

  module ClassMethods
    # @param [Hash<Symbol, Array>] relations The convertible classes with an array of convertible associations
    # @note destruction of non-convertible associations should be taken care of by dependent: :destroy
    def convertible(relations)
      cattr_accessor :convertible_classes do
        relations
      end
    end

    def is_convertible?
      true
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_convertible?
          false
        end
      end
    end

    # Useful to test whether a model uses {Trashable}
    def is_convertible?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
