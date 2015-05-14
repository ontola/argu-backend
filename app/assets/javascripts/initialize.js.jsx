/*globals ReactRailsUJS*/

Argu = window.Argu || {};

function shallowMountComponents () {
    var nodes = document.querySelectorAll('#pjax-container [data-react-class]');

    for (var i = 0; i < nodes.length; ++i) {
        var node = nodes[i];
        var className = node.getAttribute(window.ReactRailsUJS.CLASS_NAME_ATTR);

        // Assume className is simple and can be found at top-level (window).
        // Fallback to eval to handle cases like 'My.React.ComponentName'.
        var constructor = window[className] || eval.call(window, className);
        var propsJson = node.getAttribute(window.ReactRailsUJS.PROPS_ATTR);
        var props = propsJson && JSON.parse(propsJson);

        React.render(React.createElement(constructor, props), node);
    }
}

function shallowUnmountComponents () {
    var nodes = document.querySelectorAll('#pjax-container [data-react-class]');

    for (var i = 0; i < nodes.length; ++i) {
        var node = nodes[i];

        React.unmountComponentAtNode(node);
        // now remove the `data-react-class` wrapper as well
        //node.parentElement && node.parentElement.removeChild(node);
    }
}

//Lets the CSS selector know whether javascript is enabled
document.body.className = document.body.className.replace("no-js","js");

$(function (){
    "use strict";

    // All init functions can rest assured that the document is ready.
    try {
        Argu.alert.init();
        Argu.ui.init();
        Argu.n.init();

        Argu.activityFeed.init();
        Argu.m.init();
    } catch (error) {
        console.log(error);
        console.log('Something went wrong during initialisation');
    }

    function refreshCurrentActor () {
        $.ajax({
            type: 'GET',
            url: '/c_a',
            dataType: 'json',
            async: true,
            success: function (data, status, xhr) {
                if (xhr.status == 200) {
                    Actions.actorUpdate(data);
                }
            },
            error: function () {
                console.log('failed');
            }
        });
    }

    $.pjax.defaults.timeout = 10000;
    $(document)
        .pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '#pjax-container')
        .on('pjax:start pjax:beforeReplace', shallowUnmountComponents)
        .on('pjax:end', shallowMountComponents);

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
});