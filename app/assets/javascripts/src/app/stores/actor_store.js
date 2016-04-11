/* globals Actions */
import Reflux from 'reflux';

window.Actions = Reflux.createActions([
    'forumUpdate',
    'actorUpdate'
]);

const actorStore = Reflux.createStore({
    init () {
        // Register statusUpdate action
        this.listenTo(Actions.actorUpdate, this.output);
    },

    // Callback
    output (data) {
        // Pass on to listeners
        this.trigger(data.current_actor);
    }

});
window.actorStore = actorStore;
export default actorStore;
