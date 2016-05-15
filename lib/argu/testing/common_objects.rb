
module Argu
  module Testing
    module CommonObjects
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        # Searches for a `:forum` key, from most to least specific and calls its value.
        # @return [Object] The return value of the called method
        # @private
        def cascaded_forum(key, opts)
          f = key && opts.dig(key, :forum) || opts.dig(:forum) || default_cascaded_method
          send(f)
        end
      end

      module ClassMethods
        # Will normalize banged names with `preload: true` in their options hash
        # @note This modifies `args` in place
        # @return [Array, Hash] Arguments and options with their bang names adjusted
        # @example
        #   bang_to_opt!(user!, :member, forum!: [:populated, {var_name: 'holland'}])
        #    # -> [:member, user: {preload: true}, forum: [:populated, var_name: 'holland', preload: true]]
        # @private
        def bang_to_opt!(*args, **opts)
          args.reject! do |arg|
            arg = arg.to_s
            opts[arg.to_sym] = {preload: true} if arg.chomp!('!')
          end
          opts.keys.map do |k|
            key = k.to_s
            if key.chomp!('!')
              hash = opts[k].is_a?(Hash) && opts[k] || opts[k].last.is_a?(Hash) && opts[k].last
              method = hash ? :merge! : :append
              (hash || opts[k]).send(method, preload: true)
              opts[key.to_sym] = opts.delete(k)
            end
          end
          [args, opts]
        end

        # Shortcut to define the most used factory-based objects and roles like `freetown`.
        # Declare a `common_definitions` method to enable this functionality.
        # @example
        #   The `common_definitions` array should be formatted like the #define_object parameters:
        #   [variable name, factory name, *traits, **opts]
        # @note Declared items should be unique
        # @param [Array] let Objects to be initialized with their default options
        # @param [Hash] opts Objects to be initialized with given options merged with their defaults
        def define_common_objects(*let, **opts)
          let, opts = bang_to_opt!(*let, opts)
          common_definitions
            .select { |var_name, _| mdig?(var_name, let, opts) }
            .map do |var_name, factory_name = nil, *args, **def_opts|
              a = opts.dig(var_name) || {}
              if a.is_a?(Array)
                def_opts.merge!(a.pop) if a.last.is_a?(Hash)
                args.concat(a.slice!(0..-1))
              end
              f_opts = def_opts.merge(a.presence || {})
              define_object(
                var_name.to_s,
                factory_name,
                *args,
                f_opts)
            end
        end

        # Defines the factory-created object via the `let(!)` method.
        # @param [String] var_name Name of the declared variable
        # @param [String] factory_name Name of the factory to be used
        # @param [Array] args Traits to be sent to the factory
        # @param [Hash] opts Parameters for the factory
        # @option opts [Symbol] :definition_type Use `define_role_object` when set to `:role`
        # @option opts [Symbol] :preload Will use `let!` when set to `true`
        # @option opts [Symbol] :var_name Overrides the declared name
        # @private
        def define_object(var_name, factory_name, *args, **opts)
          return define_role_object(var_name, **opts) if opts[:definition_type] == :role
          l_opts = opts.deep_dup
          method = l_opts.delete(:preload) ? :let! : :let
          var_name = l_opts.delete(:var_name) || var_name
          send(method, var_name) do
            opts.each do |k, v|
              if opts[k].is_a?(Proc)
                l_opts[k] = instance_exec(&opts[k])
              elsif k == :forum && v.is_a?(Symbol)
                l_opts[k] = send(opts[k])
              end
            end
            create(*[factory_name, *args, l_opts].flatten)
          end
        end

        # Used by #define_object for the edge case of creating the standard roles,
        # which are created with the `create_role` methods.
        # @see {Argu::Testing::RoleMethods}
        # @private
        def define_role_object(var_name, **opts)
          let(var_name) do
            send("create_#{var_name}".to_sym,
                 cascaded_forum(var_name, opts))
          end
        end

        # Checks if the key is present in either args or opts.
        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @param [Hash] opts Options hash to search in.
        # @return [Boolean] Whether `key` is present in arr or hash.
        # @private
        def mdig?(key, arr, opts)
          arr.include?(key) || opts.include?(key)
        end
      end
    end
  end
end
