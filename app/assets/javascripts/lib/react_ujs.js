/*globals React, Turbolinks*/
var React = require('react/addons');

// <REQUIRE MARKER>
var bulk = require('bulk-require');
var components = bulk(__dirname, [ '../components/**/*.js' ]);
window.components = components;

// Unobtrusive scripting adapter for React
module.exports = (function ReactUJS (document, window) {
    // create the  namespace
    window.ReactRailsUJS = {
        CLASS_NAME_ATTR: 'data-react-class',
        PROPS_ATTR: 'data-react-props',
        RAILS_ENV_DEVELOPMENT: true,
        // helper method for the mount and unmount methods to find the
        // `data-react-class` DOM elements
        findDOMNodes: function(searchSelector) {
            // we will use fully qualified paths as we do not bind the callbacks
            var selector;
            if (typeof searchSelector === 'undefined') {
                selector = '[' + window.ReactRailsUJS.CLASS_NAME_ATTR + ']';
            } else {
                selector = searchSelector + ' [' + window.ReactRailsUJS.CLASS_NAME_ATTR + ']';
            }

            return document.querySelectorAll(selector);
        },

        mountComponents: function(searchSelector) {
            var nodes = window.ReactRailsUJS.findDOMNodes(searchSelector);

            for (var i = 0; i < nodes.length; ++i) {
                var node = nodes[i];
                var className = node.getAttribute(window.ReactRailsUJS.CLASS_NAME_ATTR);

                // Assume className is simple and can be found at top-level (window).
                // Fallback to eval to handle cases like 'My.React.ComponentName'.
                //var constructor = window[className] || require(className) || eval.call(window, className);
                var constructor = (typeof require === "undefined")
                    ? window[className] || eval.call(window, className)
                    : eval.call(this, className);
                var propsJson = node.getAttribute(window.ReactRailsUJS.PROPS_ATTR);
                var props = propsJson && JSON.parse(propsJson);

                React.render(React.createElement(constructor, props), node);
            }
        },

        unmountComponents: function(searchSelector) {
            var nodes = window.ReactRailsUJS.findDOMNodes(searchSelector);

            for (var i = 0; i < nodes.length; ++i) {
                var node = nodes[i];

                React.unmountComponentAtNode(node);
            }
        }
    };

    function handleNativeEvents() {
        document.addEventListener('DOMContentLoaded', function() {window.ReactRailsUJS.mountComponents()});
        window.addEventListener('unload', function() {window.ReactRailsUJS.unmountComponents()});
    }

    handleNativeEvents();
})(document, window);
