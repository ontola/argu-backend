import { ACTOR_UPDATE_SUCCESS } from '../actions';

const initialState = [];

export default function session(state = initialState, action) {
  switch (action.type) {
    case ACTOR_UPDATE_SUCCESS: {
      const { activeId, actorType } = action.payload.current_actor;
      return Object.assign(
        {},
        state,
        {
          activeId,
          actorType,
        });
    }
    default: {
      return state;
    }
  }
}
