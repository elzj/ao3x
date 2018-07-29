import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchWork } from '../../actions/workActions';
import WorkHeader from './WorkHeader'
import WorkContent from './WorkContent'
import WorkFooter from './WorkFooter'

class Work extends Component {

  componentDidMount () {
    console.log('getting work')
    this.props.fetchWork(this.props.match.params.id);
  }

  render() {
    return(
      <div>
        {this.props.work &&
          <React.Fragment>
            <WorkHeader work={this.props.work} />
            <WorkContent chapters={this.props.work.chapters} />
            <WorkFooter work={this.props.work} />
          </React.Fragment>}
      </div>
    )
  }
}

const mapStateToProps = state => ({
  work: state.works.item
});

export default connect(mapStateToProps, { fetchWork })(Work);