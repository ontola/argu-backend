# frozen_string_literal: true

module Edgeable
  module PropertyAssociations
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to(name, scope = nil, **options) # rubocop:disable Metrics/AbcSize
        opts = options.presence || scope
        return super unless opts.key?(:foreign_key_property)
        klass_name = (opts[:class_name] || name).to_s.classify
        property_options = property_options(name: opts[:foreign_key_property])
        raise "Options for #{opts[:foreign_key_property]} not found" if property_options.nil?

        has_one "#{name}_reference".to_sym,
                -> { where(predicate: property_options[:predicate].to_s) },
                class_name: 'Property',
                foreign_key: :edge_id,
                primary_key: :uuid
        source = property_options[:type] == :linked_edge_id ? :linked_edge : klass_name.underscore
        has_one name, through: "#{name}_reference".to_sym, class_name: klass_name, source: source
      end

      def has_one(name, scope = nil, **options) # rubocop:disable Metrics/AbcSize
        opts = options.presence || scope
        return super unless opts.key?(:foreign_key_property)
        klass_name = (opts[:class_name] || name).to_s.classify
        property_options = klass_name.constantize.property_options(name: opts[:foreign_key_property])
        raise "Options for #{opts[:foreign_key_property]} not found" if property_options.nil?

        has_one "#{name}_reference".to_sym,
                -> { where(predicate: property_options[:predicate].to_s) },
                class_name: 'Property',
                foreign_key: :linked_edge_id,
                primary_key: :uuid
        has_one name, through: "#{name}_reference".to_sym, class_name: klass_name, source: :edge
      end

      def has_many(name, scope = nil, **options) # rubocop:disable Metrics/AbcSize
        opts = options.presence || scope
        return super unless opts.key?(:foreign_key_property)
        klass_name = (opts[:class_name] || name).to_s.classify
        property_options = klass_name.constantize.property_options(name: opts[:foreign_key_property])
        raise "Options for #{opts[:foreign_key_property]} not found" if property_options.nil?

        has_many "#{name}_references".to_sym,
                 -> { where(predicate: property_options[:predicate].to_s) },
                 class_name: 'Property',
                 foreign_key: :linked_edge_id,
                 primary_key: :uuid
        has_many name, through: "#{name}_references".to_sym, class_name: klass_name, source: :edge
      end
    end
  end
end
