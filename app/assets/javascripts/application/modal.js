export const modal = {
    init: function () {
        $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.handleCloseModal.bind(this))
            .on('click', '.modal-container .close-trigger', this.handleCloseModal.bind(this));

        // Close modal when pressing escape button
        // @TODO: Just listen to escape, not all the time all the buttons
        document.addEventListener('keyup', function(e) {
            if (e.keyCode == 27 && !$(".no-close")[0]) {
                $('.modal-container').addClass('modal-hide');
                window.setTimeout(function () {
                    $('.modal-container').remove();
                    $('body').removeClass('modal-opened');
                }, 500);
            }
        });
    },

    handleCloseModal: function (e) {
        e.preventDefault();
        this.closeModal.bind(e.target)();
    },

    closeModal: function () {
        let container = $(this).parents('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(() => {
            container.remove();
            $('body').removeClass('modal-opened');
        }, 500);
        return true;
    }
};
