import { createSelector } from 'reselect';

export const getPersons = (state) => state.getIn(['persons', 'items']);

export const getPersonId = (state, props) => {
  if (props.params) {
    return props.params.userId;
  }

  if (props.user) {
    return props.user;
  }

  return null;
};

export const getPerson = createSelector(
  [getPersons, getPersonId],
  (persons, id) => persons.get(id)
);

export const getPersonName = createSelector([getPerson], person => {
  if (person === undefined) {
    return '';
  }
  return person.name;
});

export const getPersonUrl = createSelector([getPerson], person => {
  if (person === undefined) {
    return '';
  }
  return `/profile/${person.id}`;
});
