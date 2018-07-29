import React from 'react';
import { Link } from 'react-router-dom';
import { tagTypes } from '../../tagDefaults'

class WorkBlurb extends React.Component {
  author(creators) {
    if (creators) {
      return(
        creators.map(creator => <a href={creator.url}>{creator.name}</a>)
                .reduce((prev, curr) => [prev, ', ', curr])
      )
    } else {
      return "Nobody"
    }
  }
  fandomString() {
    return this.tagLinks('Fandom').reduce((prev, curr) => [prev, ', ', curr]);
  }
  allTags() {
    let tags = [];
    tagTypes.forEach((tagType) => {
      if (tagType != 'Fandom') {
        tags = tags.concat(this.tagLinks(tagType));
      }
    })
    return tags.reduce((prev, curr) => [prev, ', ', curr])
  }
  tagLinks(tagType) {
    const tags = this.props.work.tags;
    if (tags && tags[tagType]) {
      return tags[tagType].map(tag => <a href={tag.url} key={tag.name}>{tag.name}</a>);
    } else {
      return [];
    }
  }
  render() {
    const work = this.props.work;
    return (
      <div className="works blurb" key={work.id}>
        <h5><Link to={`/r/works/${work.id}`}>{work.title}</Link> by {this.author(work.creators)}</h5>
        <h6>{this.fandomString()}</h6>
        <div dangerouslySetInnerHTML={{__html: work.summary}}></div>
        <p className="tag-list">{this.allTags()}</p>
      </div>
    );
  }
}

export default WorkBlurb;