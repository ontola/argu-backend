$(document).on('cocoon:after-insert', function (e, insertedItem) {
    var addBlock = $(insertedItem);
    addBlock.find('.add-user').selectize({
        valueField: 'id',
        labelField: 'username',
        searchField: 'username',
        persist: false,
        create: false,
        onItemAdd: function (value, item) {
            addBlock.find('.profile-photo').attr('src', addBlock.find('[data-id="' + value + '"]').attr('data-src'));
        },
        onDelete: function () {
            addBlock.find('.profile-photo').attr('src', '/profile_photos/original/missing.png');
        },
        render: {
            option: function(item, escape) {
                return '<div class="search-result" data-id="' + escape(item.id) + '" data-src="' + escape(item.profile.profile_photo) + '"><span><img class="profile-xs" src="' + escape(item.profile.profile_photo) + '"></span><span class="label">' + escape(item.username) + '</span></div>';
            }
        },
        load: function(query, callback) {
            if (!query.length) return callback();
            $.ajax({
                url: '/users.json',
                type: 'GET',
                dataType: 'json',
                data: {
                    q: query,
                    forum_id: addBlock.closest('.forum_id').attr('id')
                },
                error: function () {
                    callback();
                },
                success: function (res) {
                    callback(res.users);
                }
            });
        }
    });
});