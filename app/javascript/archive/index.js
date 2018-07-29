import React from 'react'
import ReactDOM from 'react-dom'
import { BrowserRouter, Route } from 'react-router-dom'
import { Provider } from 'react-redux';
import store from './store';
import App from './components/App'


document.addEventListener('DOMContentLoaded', () => {
  const archive = document.querySelector('#archive')
  ReactDOM.render((
    <Provider store={store}>
      <BrowserRouter>
        <Route path='/' component={App} />
      </BrowserRouter>
    </Provider>
  ), archive)
})
