import React from 'react';
import Filters from './filters';
import Search from './search';
import {FilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {buildQuery} from '../global/utils';

export default class SearchHero extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      filters: {},
      search: null,
    };
  }

  onFiltersChange = (filters) => {
    this.setState({filters});
  };

  onSearchChange = (search) => {
    this.setState({search});
  };

  queryParams() {
    let { search, filters } = this.state;
    return {search, ...filters};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  onSubmit = () => {
    window.location.href = `${FilterPath}?${this.query()}`;
  };

  render() {
    return (
      <div className="text-center search-hero">
        <div className="welcome">
          <h3><b>Discover Seed-Stage Investors</b></h3>
          <p>
            Find the VCs that may be interested in your startup.
            Get introduced, track your conversations, and raise your seed round.
          </p>
        </div>
        <div className="float-center">
          <Filters
            showButton={!!this.query()}
            onButtonClick={this.onSubmit}
            onChange={this.onFiltersChange}
            countSource={{path: CompetitorsFilterCountPath, query: this.queryParams()}}
          />
          <p className="or">or</p>
          <Search onChange={this.onSearchChange} onSubmit={this.onSubmit} />
        </div>
      </div>
    )
  }
}