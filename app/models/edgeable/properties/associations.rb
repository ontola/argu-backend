# frozen_string_literal: true

module Edgeable
  module Properties
    module Associations
      extend ActiveSupport::Concern

      def handle_property_association_dependency(record, name, dependency)
        case dependency
        when :destroy
          record.send(name).find_each(&:destroy)
        when :restrict_with_exception
          raise ActiveRecord::DeleteRestrictionError.new(name) unless record.send(name).empty?
        else
          raise NotImplementedError unless dependency == :nullify
        end
      end

      module ClassMethods
        def has_one(name, scope = nil, **options)
          opts = options.presence || scope
          return super unless opts.is_a?(Hash) && opts.key?(:primary_key_property)

          property_association(:has_one, name, opts)
        end

        def has_many(name, scope = nil, **options)
          opts = options.presence || scope
          return super unless opts.is_a?(Hash) && (opts.key?(:foreign_key_property) || opts.key?(:primary_key_property))

          property_association(:has_many, name, opts)
        end

        private

        def property_association(type, name, opts) # rubocop:disable Metrics/MethodLength
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
            primary_key: :uuid,
            source: property_association_source(klass_name, opts, property_opts)
          )
          property_association_dependency(name, opts[:dependent]) if opts[:dependent]
        end

        def property_association_dependency(name, dependency)
          before_destroy(
            ->(record) { handle_property_association_dependency(record, name, dependency) },
            prepend: true
          )
        end

        def property_association_klass(opts, name)
          (opts[:class_name] || name).to_s.classify
        end

        def property_association_options(opts)
          foreign_key = opts.key?(:foreign_key_property) ? :edge_id : :linked_edge_id
          inverse_of = opts.key?(:foreign_key_property) ? :edge : :linked_edge

          {
            class_name: 'Property',
            dependent: property_reference_dependency(opts[:dependent]),
            foreign_key: foreign_key,
            inverse_of: inverse_of,
            primary_key: opts[:primary_key] || :uuid
          }
        end

        def property_association_property_opts(klass_name, opts)
          klass = opts.key?(:foreign_key_property) ? self : klass_name.constantize
          property = opts[:foreign_key_property] || opts[:primary_key_property]
          return if property.nil?

          property_opts = klass.send(:property_options, name: property)
          raise "Options for #{property} not found for #{klass}" if property_opts.nil?

          property_opts
        end

        def property_association_reference(name)
          "#{name}_reference".to_sym
        end

        def property_association_references(name)
          "#{name}_references".to_sym
        end

        def property_association_scope(property_opts)
          return -> { order(order: :asc) } if property_opts.nil?

          -> { order(order: :asc).where(predicate: property_opts[:predicate]) }
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
end
