const transition = {
    init: function() {
        window.addEventListener('message', e => {
            if (e.origin !== process.env.FRONTEND_URL) {
                return;
            }
            if (e.data === 'hi') {
                this.initIframeListeners();
            }
        }, false);
        parent.postMessage(
            'hello',
            process.env.FRONTEND_URL
        );

    },

    initIframeListeners: function() {
      const csrfToken = document
        .head
        .querySelector('meta[name="iframe-csrf-token"]')
        .content;
      $(document)
          .ajaxSend(function (event, jqXHR, _) {
              jqXHR.setRequestHeader(
                'x-iframe-csrf-token',
                csrfToken
              );
              jqXHR.setRequestHeader(
                'x-iframe',
                'positive'
              );
          })
          .on('turbolinks:before-visit', e => {
              e.preventDefault();
              window.postMessage(
                  { navigation: e.originalEvent.data.url },
                  process.env.FRONTEND_URL
              );
          });
      window.postMessage(
        {
            meta: {
                title: document.title
            }
        },
        process.env.FRONTEND_URL
      );
    }
};

export default transition;
