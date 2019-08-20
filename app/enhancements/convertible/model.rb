# frozen_string_literal: true

# Concern which gives Models the `convert` ability.
#
# Converts as many parameters and assocations as possible.
module Convertible
  module Model
    extend ActiveSupport::Concern

    def is_convertible?
      true
    end

    # Converts an item to another item
    # Children of models that are not whitelisted will be converted to comments
    def convert_to(klass, validate: true) # rubocop:disable Metrics/AbcSize
      raise ArgumentError.new("Conversion to #{klass.class_name} not allowed") unless convert_to?(klass)

      ActiveRecord::Base.transaction do
        new_model = becomes!(klass)
        new_model.properties = properties

        parent = new_model.parent
        parent = parent.parent until new_model.class.valid_parent?(parent.class)
        update!(parent: parent, iri_cache: nil)

        new_model.run_callbacks :convert do
          new_model.save!(validate: validate)
        end
        convert_or_destroy_children(new_model)

        {old: self, new: new_model}
      end
    end

    def convert_or_destroy_children(new_model)
      new_model.displaced_children.each do |child|
        if new_model.is_a?(Comment) && child.is_a?(Comment)
          child.parent_comment ||= new_model
          child.parent = new_model.parent
          child.save!(validate: false)
        elsif child.is_convertible? &&
            child.convert_to?(Comment) &&
            Comment.valid_parent?(self.class)
          child.convert_to(Comment, validate: false)
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
      children.reject { |edge| edge.class.valid_parent?(self.class) }
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
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def is_convertible?
        false
      end
    end

    # Useful to test whether a model uses {Trashable}
    def is_convertible?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
