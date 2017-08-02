import configureStore from './configureStore';
import Immutable from 'immutable';
import {
    RProfile
} from '../records/index';

const types = {
    profile: RProfile
};

/**
 * Replaces all the fields' values where the key matches /(D|d)ate/ with a Date object.
 * @param {Object} object An Immutable-type object.
 * @returns {Immutable/Iterable} An immutable object with its date fields replaced by Date objects
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
 * @param {*} key The key of the object
 * @param {Iterable<any, any>} value The value of the object
 * @returns {Immutable/Iterable} Immutable version of the provided tuple
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

const initialState = typeof window !== 'undefined' ? window.__INITIAL_STATE__ : undefined
function generateInitialState (state = initialState) {
    const immutableInitialState = {};
    Object
        .keys(state || {})
        .forEach(value => {
            immutableInitialState[value] = Immutable.fromJS(state[value], reviver);
        });
    return immutableInitialState;
}

const store = configureStore(generateInitialState());
export default store;

export function liveStore () {
    return configureStore(generateInitialState());
}
