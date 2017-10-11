import React from 'react';
import Filters from '../discover/filters';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {flattenFilters, buildQuery, extend, timestamp} from '../global/utils';
import createHistory from 'history/createBrowserHistory'
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';
import Switch from '../global/fields/switch';

export default class FilterPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      competitors: props.competitors,
      count: props.count,
      filters: flattenFilters(props.filters),
      search: props.search,
      options: props.options,
      resultsId: timestamp(),
    };

    this.history = createHistory();
  }

  queryParams() {
    let { search, filters, options } = this.state;
    return {search, ...filters, ...options};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  pushState = () => {
    this.history.push({search: `?${this.query()}`});
  };

  onFiltersChange = (filters, count) => {
    this.setState({filters, count, resultsId: timestamp(), competitors: null});
    this.pushState();
  };

  onSearchChange = (search) => {
    this.setState({search});
  };

  onOptionChange = name => update => {
    let options = extend(this.state.options, update);
    this.setState({options});
  };

  renderSearchAndFilters() {
    return (
      <div className="search-and-filters">
        <Row>
          <Column large={9}>
            <Filters
              showButton={false}
              showLabels={true}
              onChange={this.onFiltersChange}
              initialFilters={this.props.filters}
              initialCount={this.props.count}
              countSource={{path: CompetitorsFilterCountPath, query: this.queryParams()}}
            />
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

  renderSwitch(name, label) {
    return (
      <Switch
        name={name}
        value={this.state.options[name] || false}
        onChange={this.onOptionChange('name')}
        label={label}
      />
    );
  }

  renderSwitches() {
    return (
      <div className="option-switches">
        <Row>
          <Column large={4}>
            {this.renderSwitch('us_only', 'US Only')}
          </Column>
          <Column large={4}>
            {this.renderSwitch('related', 'Related')}
          </Column>
          <Column large={4}>
            {this.renderSwitch('company_cities', '💵 Cities')}
          </Column>
        </Row>
      </div>
    )
  }

  renderFilterRow() {
    return (
      <Row className="wide-row">
        <Column large={9}>
          {this.renderSearchAndFilters()}
        </Column>
        <Column large={3}>
          {this.renderSwitches()}
        </Column>
      </Row>
    );
  }

  render() {
    let { competitors, count, filters, resultsId } = this.state;
    let source = {path: CompetitorsFilterPath, query: filters};
    return (
      <div className="full-screen filter-page">
        <div className="filter-page-header">
          {this.renderFilterRow()}
        </div>
        <div className="filter-page-body full-screen">
          <Results count={count} competitors={competitors} source={source} resultsId={resultsId} />
        </div>
      </div>
    )
  }
}