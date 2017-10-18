export const modal = {
    init: function () {
        $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.handleCloseModal.bind(this))
            .on('click', '.modal-container .close-trigger', this.handleCloseModal.bind(this))
            .on('click', '.modal > header', this.handleCloseModal.bind(this));

        // Close modal when pressing escape button
        // @TODO: Just listen to escape, not all the time all the buttons
        document.addEventListener('keyup', function(e) {
            if (e.keyCode == 27 && !$(".no-close")[0]) {
                modal.close();
            }
        });
    },

    handleCloseModal: function (e) {
        e.preventDefault();
        modal.close();
    },

    close () {
        const bodyScrollTop = -parseInt(document.body.style.top);
        $('.modal-container').addClass('modal-hide');
        $('body').removeClass('modal-opened');

        if (typeof window !== 'undefined') {
            window.setTimeout(function () {
                $('.modal-container').remove();
            }, 500);
        }

        document.body.style.overflow = '';
        document.body.style.position = '';
        document.body.style.left = '';
        document.body.style.right = '';
        document.body.style.top = '';

        document.documentElement.scrollTop = bodyScrollTop;
        document.body.scrollTop = bodyScrollTop;

        history.pushState({ modal: true }, null, document.getElementsByClassName('modal-container')[0].dataset.previousUrl);
    },

    open: function (content, href) {
        var bodyScrollTop = document.documentElement.scrollTop || document.body.scrollTop;
        let previousUrl;

        $('body').addClass('modal-opened');

        if ($('.modal-container').length === 0) {
            if (typeof window !== 'undefined') {
                previousUrl = window.location.href;
            }
            $('.container').append(content);
            document.body.style.overflow = 'visible';
            document.body.style.position = 'fixed';
            document.body.style.left = '0';
            document.body.style.right = '0';
            document.body.style.top = -bodyScrollTop + 'px';

            history.pushState({ modal: true }, null, href);
        } else {
            previousUrl = document.getElementsByClassName('modal-container')[0].dataset.previousUrl;

            $('.modal-container').replaceWith(content);

            history.replaceState({ modal: true }, null, href);
        }
        document.getElementsByClassName('modal-container')[0].setAttribute('data-previous-url', previousUrl)
    }
};

if (typeof window !== 'undefined') {
    window.modal = modal;
    window.onpopstate = function(event){
        if (event.state.modal === true) {
            Turbolinks.visit(window.location.href, { action: 'replace' });
        }
    }
}

