import React, { Component } from 'react';
import Greeting from './Greeting';
import store from '../../store';

class Header extends Component {
  sayHi = (e) => {
    const state = store.getState();
    const w = state.works.item
    if (w && w.title) {
      alert(w.title)
    } else {
      alert('not much')
    }
  }
  render() {
    return(
      <nav className="navbar navbar-light bg-light">
        <a className="navbar-brand" href="/">AO3</a>
        <Greeting />
        <button className="btn btn-primary" type="button" onClick={this.sayHi}>
          Whatcha reading?
        </button>
      </nav>
    )
  }
}

export default Header