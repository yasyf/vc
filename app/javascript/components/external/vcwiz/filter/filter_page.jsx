import React from 'react';
import VCWiz from '../vcwiz';
import Filters from '../discover/filters';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {flattenFilters, buildQuery, extend, timestamp} from '../global/utils';
import createHistory from 'history/createBrowserHistory'
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';
import Switch from '../global/fields/switch';
import { canUseDOM } from 'exenv';

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

    if (canUseDOM) {
      this.history = createHistory();
    }
  }

  queryParams() {
    let { search, filters, options } = this.state;
    return {search, ...filters, ...options};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  pushState = () => {
    if (this.history) {
      this.history.push({search: `?${this.query()}`});
    }
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
    if (!this.props.advanced) {
      return null;
    }
    return (
      <div className="option-switches">
        <Row>
          <Column large={2}  offsetOnLarge={1}>
            {this.renderSwitch('us_only', 'US Only')}
          </Column>
          <Column large={2}>
            {this.renderSwitch('related', 'Related')}
          </Column>
          <Column large={2}>
            {this.renderSwitch('company_cities', '💵 Cities')}
          </Column>
          <Column large={5}>
            <p className="tight">"Related" finds investors who invested in similar companies, instead of exact matches.</p>
            <p className="tight">"💵 Cities" finds investors who made investments in the given locations, instead of ones based there.</p>
          </Column>
        </Row>
      </div>
    )
  }

  renderFilterRow() {
    return (
      <div>
        <Row className="wide-row">
          {this.renderSearchAndFilters()}
        </Row>
        <Row className="wide-row">
          {this.renderSwitches()}
        </Row>
      </div>
    );
  }

  renderHeader() {
    return this.renderFilterRow();
  }

  renderBody() {
    const { competitors, count, resultsId } = this.state;
    const source = {path: CompetitorsFilterPath, query: this.queryParams()};
    return (
      <Results
        count={count}
        competitors={competitors}
        source={source}
        resultsId={resultsId}
      />
    );
  }

  render() {
    return (
      <VCWiz
        page="filter"
        header={this.renderHeader()}
        body={this.renderBody()}
      />
    );
  }
}