# frozen_string_literal: true

module Edgeable
  module PropertyAssociations
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to(name, scope = nil, **options)
        opts = options.presence || scope
        return super unless opts.key?(:foreign_key_property)

        property_association(:has_one, opts, name)
      end

      def has_one(name, scope = nil, **options)
        opts = options.presence || scope
        return super unless opts.key?(:primary_key_property)

        property_association(:has_one, opts, name)
      end

      def has_many(name, scope = nil, **options)
        opts = options.presence || scope
        return super unless opts.is_a?(Hash) && (opts.key?(:foreign_key_property) || opts.key?(:primary_key_property))

        property_association(:has_many, opts, name)
      end

      private

      def property_association(type, opts, name) # rubocop:disable Metrics/MethodLength
        klass_name = property_association_klass(opts, name)
        property_opts = property_association_property_opts(klass_name, opts)

        send(
          type,
          property_association_reference(name),
          property_association_scope(property_opts),
          **property_association_options(opts)
        )
        send(
          type,
          name,
          through: property_association_reference(name),
          class_name: klass_name,
          dependent: opts[:dependent],
          source: property_association_source(klass_name, opts, property_opts)
        )
      end

      def property_association_klass(opts, name)
        (opts[:class_name] || name).to_s.classify
      end

      def property_association_options(opts)
        foreign_key = opts.key?(:foreign_key_property) ? :edge_id : :linked_edge_id

        {
          class_name: 'Property',
          dependent: property_reference_dependency(opts[:dependent]),
          foreign_key: foreign_key,
          primary_key: opts[:primary_key] || :uuid
        }
      end

      def property_association_property_opts(klass_name, opts)
        klass = opts.key?(:foreign_key_property) ? self : klass_name.constantize
        property = opts[:foreign_key_property] || opts[:primary_key_property]
        property_opts = klass.send(:property_options, name: property)
        raise "Options for #{property} not found" if property_opts.nil?

        property_opts
      end

      def property_association_reference(name)
        "#{name}_reference".to_sym
      end

      def property_association_references(name)
        "#{name}_references".to_sym
      end

      def property_association_scope(property_opts)
        -> { order(order: :asc).where(predicate: property_opts[:predicate].to_s) }
      end

      def property_association_source(klass_name, opts, property_opts)
        return :edge if opts.key?(:primary_key_property)

        property_opts[:type] == :linked_edge_id ? :linked_edge : klass_name.underscore
      end

      def property_reference_dependency(dependency)
        case dependency
        when :nullify
          :destroy
        when :destroy
          nil
        else
          dependency
        end
      end
    end
  end
end
