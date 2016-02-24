import configureStore from '../stores/configureStore';
import Immutable from 'immutable';
import {
    RProfile
} from '../records/index';
import popstate from '../actions/popstate';

const types = {
    profile: RProfile
};

/**
 * Replaces all the fields' values where the key matches /(D|d)ate/ with a Date object.
 * @param object An Immutable-type object.
 * @returns {Immutable/Iterable}
 */
function replaceDateStrings(object) {
    return object
        .map((i, k, o) => {
            return k
                .toString()
                .match(/(D|d)ate/)
                    ? new Date(o.get(k))
                    : o.get(k)
        });
}

/**
 * [Reviver function]{@link https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse#Using_the_reviver_parameter}
 * to regenerate Immutable objects for the stores.
 * @param key
 * @param value
 * @returns {Immutable/Iterable}
 */
function reviver (key, value) {
    const isIndexed = Immutable.Iterable.isIndexed(value);
    if (isIndexed) {
        return replaceDateStrings(value).toList();
    } else if (value.get('type') &&
               types.hasOwnProperty(value.get('type'))) {
        const datedObject = replaceDateStrings(value);
        const record = new types[value.get('type')](datedObject);
        return record;
    } else {
        return replaceDateStrings(value).toMap();
    }
}

function generateInitialState (state = window.__INITIAL_STATE__) {
    var immutableInitialState = {};
    Object
        .keys(state || {})
        .forEach((value) => {
            immutableInitialState[value] = Immutable.fromJS(state[value], reviver);
        });
    return immutableInitialState;
}

const store = configureStore(generateInitialState());
export default store;

export function liveStore () {
    return configureStore(generateInitialState());
}
