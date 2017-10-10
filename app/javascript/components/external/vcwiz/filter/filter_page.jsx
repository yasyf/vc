import React from 'react';
import Filters from '../discover/filters';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {flattenFilters, buildQuery} from '../global/utils';
import createHistory from 'history/createBrowserHistory'
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';

export default class FilterPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      competitors: props.competitors,
      count: props.count,
      filters: flattenFilters(props.filters),
      search: props.search,
    };

    this.history = createHistory();
  }

  queryParams() {
    let { search, filters } = this.state;
    return {search, ...filters};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  pushState = () => {
    this.history.push({search: `?${this.query()}`});
  };

  onFiltersChange = (filters, count) => {
    this.setState({filters, count, competitors: null});
    this.pushState();
  };

  onSearchChange = (search) => {
    this.setState({search});
  };

  renderSearchAndFilters() {
    return (
      <div className="search-and-filters">
        <Row>
          <Column large={8}>
            <Filters
              showButton={false}
              showLabels={true}
              onChange={this.onFiltersChange}
              initialFilters={this.props.filters}
              initialCount={this.props.count}
              countSource={{path: CompetitorsFilterCountPath, query: this.queryParams()}}
            />
          </Column>
          <Column large={1}>
            <p className="or">or</p>
          </Column>
          <Column large={3}>
            <Search
              value={this.props.search}
              onChange={this.onSearchChange}
            />
          </Column>
        </Row>
      </div>
    );
  }

  render() {
    let { competitors, count, filters } = this.state;
    let source = {path: CompetitorsFilterPath, query: filters};
    return (
      <div className="full-screen filter-page">
        <div className="filter-page-header">
          {this.renderSearchAndFilters()}
        </div>
        <div className="filter-page-body full-screen">
          <Results count={count} competitors={competitors} source={source} />
        </div>
      </div>
    )
  }
}