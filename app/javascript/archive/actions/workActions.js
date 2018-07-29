import { FETCH_WORKS, FETCH_WORK } from './types';

export const fetchWorks = (q) => dispatch => {
  q && q.length > 0 &&
  fetch(`/api/works?q=${q}`)
    .then(res => res.json())
    .then(works =>
      dispatch({
        type: FETCH_WORKS,
        payload: works
      })
    );
};

export const fetchWork = (id) => dispatch => {
  id && id.length > 0 &&
  fetch(`/api/works/${id}`)
    .then(res => res.json())
    .then(work => {
      console.log(work)
      dispatch({
        type: FETCH_WORK,
        payload: work
      })}
    );
};