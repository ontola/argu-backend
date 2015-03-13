/*globals ReactRailsUJS*/

$(function (){
    "use strict";

    //Lets the CSS selector know whether javascript is enabled
    document.body.className = document.body.className.replace("no-js","js");

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

    var refreshing = false,
        lastNotificationCheck = Date.now(),
        timeoutValue = 30000,
        notificationTimeout;

    function refreshComments() {
        if (lastNotification && !refreshing && Date.now() - lastNotificationCheck >= 15000) {
            window.clearTimeout(notificationTimeout);
            refreshing = true;
            lastNotificationCheck = Date.now();
            $.ajax({
                type: 'GET',
                url: '/notifications',
                dataType: 'json',
                async: true,
                headers: {
                    lastNotification: lastNotification
                },
                success: function (data, status, xhr) {
                    if (xhr.status == 200) {
                        NotificationActions.notificationUpdate(data.notifications);
                    }
                },
                error: function () {
                    console.log('failed');
                },
                complete: function () {
                    refreshing = false;
                    resetTimeout();
                }
            });
        } else if (!refreshing) {
            resetTimeout();
        }
    }

    function resetTimeout() {
        window.clearTimeout(notificationTimeout);
        notificationTimeout = window.setTimeout(refreshComments, timeoutValue);
    }
    resetTimeout();

    $(function () {
        var hidden, visibilityChange;
        if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
            hidden = "hidden";
            visibilityChange = "visibilitychange";
        } else if (typeof document.mozHidden !== "undefined") {
            hidden = "mozHidden";
            visibilityChange = "mozvisibilitychange";
        } else if (typeof document.msHidden !== "undefined") {
            hidden = "msHidden";
            visibilityChange = "msvisibilitychange";
        } else if (typeof document.webkitHidden !== "undefined") {
            hidden = "webkitHidden";
            visibilityChange = "webkitvisibilitychange";
        }

        function handleVisibilityChange() {
            if (document[hidden]) {
                timeoutValue = 120000;
                resetTimeout();
            } else {
                timeoutValue = 30000;
                refreshComments();
            }
        }

        document.addEventListener(visibilityChange, handleVisibilityChange, false);
        $(document).on('pjax:complete', function (e,xhr) {
            if (Date.parse(xhr.getResponseHeader('lastNotification')) > Date.parse(window.lastNotification)) {
                refreshComments();
            } else {
                resetTimeout();
            }
        });
    });

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
});