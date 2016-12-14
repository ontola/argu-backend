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

  # Converts an item to another item, the convertible method was used,
  # those relations will be assigned the newly created model
  #
  # TODO: check if the receiving model has the same associated_model names before sending them over (else, delete)
  def convert_to(klass)
    unless convertible_classes.include?(klass.class_name.to_sym)
      raise ArgumentError.new("Conversion to #{klass.class_name} not allowed")
    end

    ActiveRecord::Base.transaction do
      shared_attributes = klass.column_names.reject { |n| !attribute_names.include?(n) || n == 'id' }
      new_model = klass.new Hash[shared_attributes.map { |i| [i, attributes[i]] }]
      new_model.edge = edge
      until new_model.parent_classes.include?(new_model.edge.parent.owner_type.underscore.to_sym)
        new_model.edge.parent = new_model.edge.parent.parent
      end
      new_model.save!
      convertible_classes[klass.class_name.to_sym].each do |association|
        klass_association = self.class.reflect_on_association(association)
        # Just to be sure
        next unless klass_association.macro == :has_many
        remote_association_name = klass_association.options[:as]
        send(association).each do |associated_model|
          associated_model.send("#{remote_association_name}=", new_model)
          associated_model.save!
        end
        send(association).clear
      end
      # Reload to make sure the Edge is no longer marked as dependent
      reload
      {old: destroy, new: new_model}
    end
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
