import React, { Component } from 'react';
import { Switch, Route } from 'react-router-dom'
import WorksIndex from './WorksIndex'
import WorkForm from './WorkForm'
import Work from './Work'

class Works extends Component {
  render() {
    return(
      <Switch>
        <Route exact path='/r/works' component={WorksIndex}/>
        <Route path='/r/works/new' component={WorkForm}/>
        <Route path='/r/works/:id' component={Work}/>
      </Switch>
    )
  }
}

export default Works