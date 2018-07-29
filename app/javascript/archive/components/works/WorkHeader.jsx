import React, { Component } from 'react';
import { tagTypes } from '../../tagDefaults'

class WorkHeader extends Component {
  sayHi = (e) => {
    e.preventDefault;
    const meta = document.getElementById('workmeta');
    meta.classList.toggle("show")
  }

  render() {
    const displayType = (type) => {
      switch(type) {
        case 'Rating':
          return type
        case 'Freeform':
          return 'Additional Tags'
        default:
          return `${type}s`
      }
    }

    const listTags = (type) => {
      const tags = this.props.work.tags[type]
      if (tags) {
        const list = tags
          .map(tag => <a href={tag.url} key={tag.name}>{tag.name}</a>)
          .reduce((prev, curr) => [prev, ', ', curr])

        return(
          <React.Fragment key={type}>
            <dt>{displayType(type)}</dt>
            <dd>{list}</dd>
          </React.Fragment>
        )
      }
    }

    return(
      <div className="work header">
        <button className="btn btn-primary float-right" type="button" data-toggle="collapse" data-target="workmeta" onClick={this.sayHi}>
         &times;
        </button>
        <dl className="meta collapse show" id='workmeta'>
          {tagTypes.map((tagtype) => listTags(tagtype))}
          <dt>Language</dt>
          <dd>{this.props.work.language}</dd>
          <dt>Stats</dt>
          <dd>
            <dl className='stats'>
              <dt>Published At</dt>
              <dd>{this.props.work.revised_at}</dd>
              <dt>Word Count</dt>
              <dd>{this.props.work.word_count}</dd>
              <dt>Chapters</dt>
              <dd>{this.props.work.chapter_display}</dd>
            </dl>
          </dd>
        </dl>

        <h2>{this.props.work.title}</h2>
        <h3 className="byline">{this.props.work.creators.map(c => c.name).join(', ')}</h3>

        {this.props.work.summary &&
          <div className='summary'>
            <h6>Summary</h6>
            <div dangerouslySetInnerHTML={{__html: this.props.work.summary}}></div>
          </div>}

        {this.props.work.notes && 
          <div className='notes'>
            <h6>Notes</h6>
            <div dangerouslySetInnerHTML={{__html: this.props.work.notes}}></div>
          </div>}
      </div>
    )
  }
}

export default WorkHeader