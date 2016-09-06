import { createSelector } from 'reselect';

export const getActor = state => state.getIn(['current-actors', 'items', 'currentactor']);
