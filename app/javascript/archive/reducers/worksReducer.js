import { FETCH_WORKS, FETCH_WORK } from '../actions/types';

const initialState = {
  works: [],
  work: null
};

export default function(state = initialState, action) {
  switch (action.type) {
    case FETCH_WORK:
      return {
        ...state,
        item: action.payload
      };
    case FETCH_WORKS:
      return {
        ...state,
        items: action.payload
      };
    default:
      return state;
  }
}
