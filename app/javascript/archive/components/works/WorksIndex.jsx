import React from 'react';
import queryString from 'query-string';
import ReactPaginate from 'react-paginate';
import WorkBlurb from './WorkBlurb';
import SearchForm from './SearchForm';

class WorksIndex extends React.Component {
  state = {
    works: [],
    pageCount: 1,
    currentPage: 1
  }

  handlePageClick = (data) => {
    this.fetchWorks({q: this.getSearchQuery(), page: data.selected + 1});
  };

  searchWorks = (q) => {
    this.fetchWorks({q: q, page: 1});
  }

  fetchWorks = (queryOptions) => {
    if (!queryOptions.q) {
      return;
    }
    const params = queryString.stringify(queryOptions);
    const path = `/works?${params}`;
    fetch(`/api${path}`)
      .then(response => response.json())
      .then(data => {
        this.setState({
          works: data.works,
          pageCount: data.page_count,
          currentPage: queryOptions.page
        });
        this.props.history.push('/r' + path);
      })
      .catch(error => {
        console.error(error);
      });
  }

  getSearchQuery = () => {
    const params = queryString.parse(this.props.location.search);
    if (params.q) {
      return params.q;
    } else {
      return '';
    }
  }

  getCurrentPage = () => {
    const params = queryString.parse(this.props.location.search);
    if (params.page) {
      return params.page;
    } else {
      return 1;
    }
  }

  componentDidMount () {
    this.fetchWorks({
      q: this.getSearchQuery(),
      page: this.getCurrentPage()
    });
  }

  render() {
    let message;
    let pagination;
    if (this.state.pageCount > 0) {
      message = `Search results: page ${this.state.currentPage} of ${this.state.pageCount}`;
      pagination = <ReactPaginate previousLabel={"previous"}
                       nextLabel={"next"}
                       breakLabel={<a href="">...</a>}
                       breakClassName={"break-me page-item"}
                       pageCount={this.state.pageCount}
                       marginPagesDisplayed={2}
                       pageRangeDisplayed={5}
                       onPageChange={this.handlePageClick}
                       containerClassName={"pagination"}
                       pageClassName={"page-item"}
                       pageLinkClassName={"page-link"}
                       previousClassName={"page-item"}
                       nextClassName={"page-item"}
                       activeClassName={"active"}
                       forcePage={this.state.currentPage - 1} />

    } else {
      message = "Sorry, that search didn't return any results"
    }
    return (
      <React.Fragment>
        <SearchForm searchWorks={this.searchWorks} getValue={this.getSearchQuery} />
        <p>{message}</p>
        {this.state.works.map((work) => <WorkBlurb work={work} key={work.id} />)}
        {pagination}
      </React.Fragment>
    );
  }
}

export default WorksIndex;