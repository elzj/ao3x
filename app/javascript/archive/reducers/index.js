import { combineReducers } from 'redux';
import { reducer as formReducer } from 'redux-form';
import worksReducer from './worksReducer';

export default combineReducers({
  form: formReducer,
  works: worksReducer
});
