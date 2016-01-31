module Argu
  class StatefulServerRenderer < React::ServerRendering::ExecJSRenderer
      def initialize(options={})
        @replay_console = options.fetch(:replay_console, true)
        filenames = options.fetch(:files, ["react-server.js", "components.js"])
        js_code = CONSOLE_POLYFILL.dup

        filenames.each do |filename|
          js_code << ::Rails.application.assets[filename].to_s
        end

        super(options.merge(code: js_code))
      end

      def after_render(component_name, props, prerender_options)
        @replay_console ? CONSOLE_REPLAY : ''
      end

      # Reimplement console methods for replaying on the client
      CONSOLE_POLYFILL = <<-JS
        var console = { history: [] };
        ['error', 'log', 'info', 'warn'].forEach(function (fn) {
          console[fn] = function () {
            console.history.push({level: fn, arguments: Array.prototype.slice.call(arguments)});
          };
        });
      JS

      # Replay message from console history
      CONSOLE_REPLAY = <<-JS
        (function (history) {
          if (history && history.length > 0) {
            result += '\\n<scr'+'ipt>';
            history.forEach(function (msg) {
              result += '\\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(msg.arguments) + ');';
            });
            result += '\\n</scr'+'ipt>';
          }
        })(console.history);
      JS

    def render(component_name, props, prerender_options)
      # pass prerender: :static to use renderToStaticMarkup
      react_render_method = if prerender_options == :static
                              "renderToStaticMarkup"
                            else
                              "renderToString"
                            end
      _prerender_options = {
        render_function: react_render_method
      }
      _prerender_options.merge!(prerender_options) if prerender_options.is_a?(Hash)

      if !props.is_a?(String)
        props = props.to_json
      end

      super(component_name, props, _prerender_options)
    end

    def before_render(component_name, props, prerender_options)
      initial_js_state = prerender_options.fetch(:initial_state, {}).to_json
      "window.__INITIAL_STATE__ = #{initial_js_state};"
    end
  end
end
