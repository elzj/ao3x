import React from 'react';

class SearchForm extends React.Component {
  state = { value: '' };

  componentDidMount () {
    if (this.state.value == '') {
      this.setState({value: this.props.getValue()})
    }
  }

  handleChange = (event) => {
    this.setState({value: event.target.value});
  }

  handleSubmit = (event) => {
    event.preventDefault();
    this.props.searchWorks(this.state.value);
  }

  render() {
    return(
      <form onSubmit={this.handleSubmit} className = "search form-inline" action="/works" acceptCharset="UTF-8" method="get">
        <input type="text" name="query" value={this.state.value} onChange={this.handleChange} placeholder="Search" />
        <button type="submit" className="btn btn-primary">Submit</button>
      </form>
    )
  }
}

export default SearchForm