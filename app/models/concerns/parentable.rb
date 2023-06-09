# frozen_string_literal: true

# Concern that gives models the `Parentable` functionality in cooperation with {Context}
#
# A model using Parentable needs to call {Parentable::ClassMethods#parentable} to define which associations
# qualify to be parent.
module Parentable
  extend ActiveSupport::Concern

  included do
    # Simple method to verify that a model uses {Parentable}
    def is_fertile?
      true
    end

    def self.is_fertile?
      true
    end

    def parent
      self.class.parent_classes.detect { |t| break send(t) if send(t) }
    end

    delegate :ancestor, to: :parent, allow_nil: true

    def root
      parent.try(:root) || ancestor(:page)
    end

    def parent_iri(**opts)
      parent&.iri(**opts)
    end

    def parent_iri_path(**opts)
      split_iri_segments(parent&.root_relative_iri(**opts))
    end

    def singular_iri_opts
      {
        parent_iri: parent_iri_path
      }
    end
  end

  module ClassMethods
    # Add to a model which includes {Parentable} to set the possible parents for the model
    # @param relation [Symbol splat] List of symbolized model names.
    def parentable(*relation)
      class_attribute :parent_classes
      self.parent_classes = relation
    end

    def valid_parent?(klass)
      parent_classes.any? { |parent_klass| klass <= parent_klass.to_s.classify.constantize }
    end
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :parent, key: :parent, predicate: NS.schema.isPartOf, polymorphic: true
      # rubocop:enable Rails/HasManyOrHasOneDependent
    end
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def is_fertile?
        false
      end
    end

    # Useful to test whether a model is (not) fertile
    def is_fertile?
      false
    end
  end
  ActiveRecord::Base.include ActiveRecordExtension
end
