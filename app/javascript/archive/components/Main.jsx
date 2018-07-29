import React, { Component } from 'react';
import { Switch, Route } from 'react-router-dom'
import Home from './home'
import Works from './works'

class Main extends Component {
  render() {
    return(
      <Switch>
        <Route exact path='/' component={Home}/>
        <Route path='/r/works' component={Works}/>
      </Switch>
    )
  }
}

export default Main