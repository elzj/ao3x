import React, { Component } from 'react';
import currentUser from '../../currentUser';

class Greeting extends Component {
  render() {
    const user = currentUser()
    let userLinks

    if (user.loggedIn) {
      userLinks = (
        <React.Fragment>
          <li className="nav-item">
            Hey there, {user.name}
          </li>
          <li className="nav-item">
            <a href='/users/sign_out'>
              Log Out
            </a>
          </li>
        </React.Fragment>
      )
    } else {
      userLinks = (
         <li className="nav-item">
          <a href='/users/sign_in'>Log in</a>
        </li>
      )
    }
    return(
      <ul className="nav justify-content-end">
        {userLinks}
      </ul>
    )
  }
}

export default Greeting