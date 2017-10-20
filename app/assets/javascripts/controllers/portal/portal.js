/* globals $ */

const portal = {
    init () {
        $(document)
          .on('turbolinks:load', this.handleDOMChangedFinished);

        this.handleDOMChangedFinished();
    },

    handleDOMChangedFinished () {
        portal.handleEditableSettings();
    },

    handleEditableSettings () {
        let settings;
        if ((settings = $('.settings-table'))) {
            const editableOptions = {
                onsubmit (e) {
                    e.target = '/portal/setting/';
                },
                submitdata () {
                    return { key: this.getAttribute('id') };
                },
                indicator: 'Saving...',
                tooltip: 'Click to edit...'
            };

            settings.find('.setting .value').editable('', editableOptions);

            settings.find('.add-setting').click(() => {
                const key = window.prompt('Enter the key', '');
                if (key !== null && key.length > 0) {
                    const newSetting = $('<tr class="setting"><td class="key">' + key + '</td><td class="value" id="' + key + '" title="Click to edit..."></td></tr>');
                    $('.settings-table tbody').append(newSetting);
                    newSetting.find('.value').editable('', editableOptions);
                }
            });
        }
    }
};

portal.init();
