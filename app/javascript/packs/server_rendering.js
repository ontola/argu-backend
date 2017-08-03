// By default, this pack is loaded for server-side rendering.
// It must expose react_ujs as `ReactRailsUJS` and prepare a require context.
self.I18n = require('i18n-js');
require('../../assets/javascripts/i18n/translations');
var componentRequireContext = require.context("../components", true)
var ReactRailsUJS = require("react_ujs")
ReactRailsUJS.useContext(componentRequireContext)
