window.Actions = Reflux.createActions([
    "forumUpdate",
    "actorUpdate"
]);

window.actorStore = Reflux.createStore({
    init: function() {
        // Register statusUpdate action
        this.listenTo(Actions.actorUpdate, this.output);
    },

    // Callback
    output: function(flag) {
        // Pass on to listeners
        this.trigger(flag);
    }

});
