import React, { Component } from 'react';
import { fetchChapter } from '../../actions/workActions';

class WorkContent extends Component {
  render() {
    return(
      <div className='chapters'>
        {this.props.chapters && this.props.chapters.map(chapter =>
          <div className='chapter' key={chapter.id}>
            <h3>{chapter.title ? chapter.title : `Chapter ${chapter.position}`}</h3>
            <div dangerouslySetInnerHTML={{__html: chapter.content}}>
            </div>
         </div>)}
      </div>
    )
  }
}

export default WorkContent