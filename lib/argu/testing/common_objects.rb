
module Argu
  module Testing
    module CommonObjects
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        def cascaded_forum(key, opts)
          f = key && opts.dig(key, :forum) || opts.dig(:forum) || :freetown
          send(f)
        end
      end

      module ClassMethods
        COMMON_OBJECTS = [
          [:var_name, :factory_name, :def_opts],
          [:freetown, :forum, {name: 'freetown'}],
          [:user, :user],
          [:staff, :user, :staff],
          [:member, definition_type: :role],
          [:manager, definition_type: :role],
          [:owner, definition_type: :role],
          [:page, :page]
        ].freeze

        # Shortcut to define the most used objects and roles like `freetown`
        def define_common_objects(*let, **opts)
          COMMON_OBJECTS
            .select { |var_name, _| mdig?(var_name, let, opts) }
            .map do |var_name, factory_name = nil, *args, **def_opts|
              a = opts.dig(var_name) || {}
              if a.is_a?(Array) && a.last.is_a?(Hash)
                merger = a.pop
                args.concat(a)
              end
              f_opts = def_opts.merge(merger || a)
              define_object(
                var_name,
                factory_name,
                *args,
                f_opts)
            end
        end

        def define_object(var_name, factory_name, *args, **opts)
          return define_role_object(var_name, **opts) if opts[:definition_type] == :role
          l_opts = opts.deep_dup
          let var_name do
            l_opts.each do |k, _v|
              l_opts[k] = instance_exec(&opts[k]) if opts[k].is_a?(Proc)
            end
            create(*[factory_name, *args, l_opts].flatten)
          end
        end

        def define_role_object(var_name, **opts)
          let(var_name) do
            send("create_#{var_name}".to_sym,
                 cascaded_forum(var_name, opts))
          end
        end

        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @param [Hash] opts Options hash to search in.
        # @return [Boolean] Whether `key` is present in arr or hash.
        def mdig?(key, arr, opts)
          arr.include?(key) || opts.include?(key)
        end
      end
    end
  end
end
