// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require fetch/fetch
//= require jquery/dist/jquery.js
//= require jquery_ujs
//= require reflux/dist/reflux.js
//= require jquery.jeditable.mini.js
//= require jquery-ui/autocomplete
//= require jquery-ui/sortable
//= require jquery-pjax/jquery.pjax
//= require microplugin/src/microplugin
//= require sifter/sifter.js
//= require selectize/dist/js/selectize.js
//= require classnames
// Briarcliff dependencies :: GO
//= require fastclick/lib/fastclick
//= require intro.js/intro.js
//= require nprogress/nprogress.js
// Briarcliff dependencies :: END
//= require autocomplete-rails
//= require_tree ./lib
//= require_tree ./stores
//= require_tree ./services
import React from 'react/react-with-addons';
window.React = React;
import Intl from 'intl';
import ReactIntl from 'react-intl';
import './lib/helpers';
import './lib/OrderedMap';
import './components/CombiBigVote';
import './components/_big_group_responses';
import './components/_big_vote_elements';
import './components/_expand';
import './components/_membership';
import './components/_search';
import './components/ActiveToggle';
import './components/CurrentProfile';
import './components/Dropdown';
import './components/Notifications';
import App from 'initialize';
App().init();
