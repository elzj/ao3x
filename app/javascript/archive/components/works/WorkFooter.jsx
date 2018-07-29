import React, { Component } from 'react';

class WorkFooter extends Component {
  render() {
    return(
      <div className='footer'>
        {this.props.work.endnotes &&
          <div className='notes'>
            <h6>End Notes</h6>
            <div dangerouslySetInnerHTML={{__html: this.props.work.endnotes}}>
            </div>
          </div>}
      </div>
    )
  }
}

export default WorkFooter