/*global $, Argu*/

$(function () {
    if (!Argu.card) Argu.card = {};
    if (!Argu.card.cards) Argu.card.cards = [];
    var _doc = $(document),
        inline;

    Argu.Card = function (name, page, fullscreen) {
        var card_url = '/cards/'+name;
        var card = this, _card, orig_sortable,
            scribe, scribeToolbar, inline;

        if($('#'+name).length > 0) {
            console.log('singularize');
            for (var i = 0; i < Argu.card.cards.length; i++){
                if(Argu.card.cards[i].getName() === name) return Argu.card.cards[i];
            }
        } else {
            Argu.card.cards.push(card);
        }

        var cancel = function () {
            if(_card.hasClass('editing')) {
                cancelEdit();
            } else {
                card.unload();
            }
        };

        var cancelEdit = function () {
            if(window.confirm('Alle wijzigingen zullen verloren gaan')) {
                _card.find('.btn-cancel').off('click', cancelEdit);
                _card.find('nav ul').sortable('destroy');
                _card.find('nav ul').empty().append(orig_sortable);
                teardownScribe();
                setTimeout(function () {
                    _card.removeClass('editing');
                    setTimeout(card.load, 100);
                }, 100);
            }
        };

        var displayPage = function (_page) {
            _card.find('article.new-card-page').remove();
            _card.find('article.active, .toolbar.active').removeClass('active');
            _card.find('article#'+_page + ', #toolbar-'+_page).addClass('active');
            page = _page;
        };

        var insertPage = function (title, htmlString) {
            _card.find('nav ul').append('<li><a rel=tab name="' + name + '" href="#'+title+'">'+title+'</a></li>');
            _card.find('nav').after(htmlString);
        };

        var initializeScribe = function () {
            _card.find('article:not(.new-card-page)').each(function (i) {
                var _scribe = new scribe(this);
                //scribe.use(imageHandler());
                _scribe.on('content-changed', function () {
                    document.querySelector('#card_card_pages_attributes_' + i + '_contents').value = _scribe.getHTML();
                });
                // Use some plugins
                _scribe.use(scribeToolbar(document.querySelector('#toolbar-'+ this.id)));
            });
        };

        var renderCard = function (htmlString) {
            _card = $(htmlString).prependTo('body');
            setupCard();
        };

        var renderCardPage = function (htmlString) {
            _card.find('article.active').removeClass('active');
            _card.find('nav').after(htmlString).addClass('active');
        };

        var setupCard = function () {
            if((page = page || _card.find('nav ul li:first-child a[ref=tab]').attr('name'))) card.showPage(page);
            if(fullscreen === true) _card.addClass('fullscreen');
            handlers.setupHandlers();
            _card.fadeIn('fast');
        };

        var teardownScribe = function () {
            _card.find('article:not(.new-card-page)').each(function (i) {
                //Not truly supported by scribe yet
                this.removeAttribute('contenteditable');
            });
        };

        var handlers = {
            addPageHandler: function(e) {
                card.showAddCardPage(_card.attr('id'));
            },
            addPageSuccess: function (data, status, xhr) {
                console.log('success');
            },
            clickHandler: function(e) {
                if(e.target.tagName == 'SECTION') cancel();
                if(e.target.getAttribute('ref') === 'tab') {
                    e.preventDefault();
                    card.showPage(e.target.getAttribute('name'));
                }
            },
            editHandler: function () {
                card.enterEditMode();
            },
            keyHandler: function (e) {
                if(e.keyCode == 27) cancel();
            },
            popstate: function (event) {
                if(event.state && event.state.card && event.state.card.name === name) {
                    displayPage(event.state.card.page);
                }
            },
            setupHandlers: function () {
                _card.on('click', 'a.btn.add-page', handlers.addPageHandler);
                _card.on('click', '.full-icon', handlers.toggleFullscreen);
                _card.on('click', '.edit-btn', handlers.editHandler);
                _card.on('click', '', handlers.clickHandler);
                _doc.on('keyup', '', handlers.keyHandler);
                window.addEventListener('popstate', handlers.popstate);
            },
            teardownHandlers: function () {
                _card.off('click', 'a.btn.add-page', handlers.addPageHandler);
                _card.off('click', '', handlers.clickHandler);
                _doc.off('keyup', '', handlers.keyHandler);
                window.removeEventListener('popstate', handlers.popstate);
            },
            toggleFullscreen: function () {
                fullscreen = !fullscreen;
                if(fullscreen) _card.addClass('fullscreen');
                else _card.removeClass('fullscreen');
            }
        };

        /*
         * Public functions
         */

        this.showAddCardPage = function () {
            $.get(card_url + '/pages/new', renderCardPage, 'json')
                .always(function() {
                    //@TODO
                    _card.find('form').on('ajax:success', handlers.addPageSuccess);
                });
        };

        this.showPage = function (_page) {
            displayPage(_page);
            history.pushState({"card": { "name": name, "page": _page }}, '', '');
        };

        this.enterEditMode = function () {
            if(!_card.hasClass('editing')) {
                if(scribe !== undefined) {
                    _card.addClass('editing');
                    _card.find('.btn-cancel').on('click', cancelEdit);
                    orig_sortable = _card.find('nav ul li').clone();
                    _card.find('nav ul').sortable({
                        cursor: "move",
                        update: function () {
                            _card.find('#card_pages_index').val(_card.find('nav ul').sortable('serialize', {key: 'card_pages_index'}));
                        }
                    });
                    _card.find('form.edit-form').on('ajax:complete', card.load);
                    initializeScribe();
                } else {
                    new Argu.Alert('Editor nog niet geladen', 'warning').show();
                }
            } else {
                new Argu.Alert('Pagina wordt al bewerkt', 'warning').show();
            }
        };

        this.load = function () {
            if(_card) card.unload(1000);
            $.get(card_url, renderCard, 'json');
        };

        this.unload = function (timeOut) {
            handlers.teardownHandlers();
            _card.fadeOut((timeOut || 'fast'), function () {
                $(this).remove();
            });
        };

        this.getName = function() {
            return name;
        };

        /*
         * Scribe init
         */
        require.config({ paths: {
            'scribe': '/assets/scribe',
            'scribePluginToolbar': '/assets/scribe-plugin-toolbar',
            'imagehandler': '/assets/imagehandler'
        }});
        require(['scribe', 'scribePluginToolbar', 'imagehandler'], function (Scribe, scribePluginToolbar, imageHandler) {
            scribe = Scribe;
            scribeToolbar = scribePluginToolbar;
        });
        this._bindToElement = function (element, _inline) {
            inline = _inline;
            _card = $(element);
            setupCard();
        };
    };

    /*
     * Event handlers
     */
    _doc.on('click', 'a[rel=tag]', function (e) {
        e.preventDefault();
        new Argu.Card(this.getAttribute('name')).load();
    });
    if((inline = _doc.find('section.card.inline')).length) {
        console.log(inline.attr('id'));
        new Argu.Card(inline.attr('id'))._bindToElement(inline, true);
    }
});