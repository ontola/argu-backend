
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

        def bang_to_opt!(*args, **opts)
          args.reject! do |arg|
            arg = arg.to_s
            opts[arg.to_sym] = {preload: true} if arg.chomp!('!')
          end
          opts.keys.map do |k|
            key = k.to_s
            if key.chomp!('!')
              method = opts[k].is_a?(Array) ? :append : :merge
              opts[key.to_sym] = opts.delete(k).send(method, preload: true)
            end
          end
          [args, opts]
        end

        # Shortcut to define the most used objects and roles like `freetown`
        # @note Declared items should be unique
        # @param [Array] let
        # @param [Hash] opts
        def define_common_objects(*let, **opts)
          let, opts = bang_to_opt!(*let, opts)
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
                var_name.to_s,
                factory_name,
                *args,
                f_opts)
            end
        end

        # @param [String] var_name Name of the declared variable
        # @param [String] factory_name Name of the factory to be used
        # @param [Array] args Traits to be sent to the factory
        # @param [Hash] opts Parameters for the factory
        # @option opts [Symbol] :definition_type Use `define_role_object` when set to `:role`
        # @option opts [Symbol] :preload Will use `let!` when set to `true`
        def define_object(var_name, factory_name, *args, **opts)
          return define_role_object(var_name, **opts) if opts[:definition_type] == :role
          l_opts = opts.deep_dup
          method = l_opts.delete(:preload) ? :let! : :let
          send(method, var_name) do
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
