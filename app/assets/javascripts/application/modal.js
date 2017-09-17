export const modal = {
    init: function () {
        $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.handleCloseModal.bind(this))
            .on('click', '.modal-container .close-trigger', this.handleCloseModal.bind(this));

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
    },

    open: function (content) {
        var bodyScrollTop = document.documentElement.scrollTop || document.body.scrollTop;
        $('body').addClass('modal-opened');

        if ($('.modal-container').length === 0) {
            $('.container').append(content);
            document.body.style.overflow = 'visible';
            document.body.style.position = 'fixed';
            document.body.style.left = '0';
            document.body.style.right = '0';
            document.body.style.top = -bodyScrollTop + 'px';
        } else {
            $('.modal-container').replaceWith(content);
        }
    }
};

if (typeof window !== 'undefined') {
    window.modal = modal;
}
