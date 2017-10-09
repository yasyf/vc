import React from 'react';
import Filters from '../discover/filters';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {flattenFilters, buildQuery} from '../global/utils';
import createHistory from 'history/createBrowserHistory'

export default class FilterPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      competitors: props.competitors,
      count: props.count,
      filters: flattenFilters(this.props.filters),
    };

    this.history = createHistory();
  }

  onFilterChange = (filters, count) => {
    if (!_.isEqual(filters, this.state.filters)) {
      this.setState({filters, count, competitors: null});
      this.history.push({search: `?${buildQuery(filters)}`});
    }
  };

  queryParams() {
    let { filters } = this.state;
    return {...filters};
  }

  render() {
    let { competitors, count, filters } = this.state;
    let source = {path: CompetitorsFilterPath, query: filters};
    return (
      <div className="full-screen">
        <Filters
          showButton={false}
          showLabels={true}
          onChange={this.onFilterChange}
          initialFilters={this.props.filters}
          initialCount={this.props.count}
          countSource={{path: CompetitorsFilterCountPath, query: this.queryParams()}}
        />
        <div className="filter-page full-screen">
          <Results count={count} competitors={competitors} source={source} />
        </div>
      </div>
    )
  }
}