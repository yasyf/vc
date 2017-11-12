import React from 'react';
import VCWiz from '../vcwiz';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {
  flattenFilters,
  buildQuery,
  extend,
  timestamp,
  replaceSort,
} from '../global/utils';
import createHistory from 'history/createBrowserHistory'
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';
import Switch from '../global/fields/switch';
import { canUseDOM } from 'exenv';
import FilterRow from '../discover/filter_row';

export default class FilterPage extends React.Component {
  static defaultProps = {
    advanced: true,
  };

  constructor(props) {
    super(props);

    this.state = {
      competitors: props.competitors,
      count: props.count,
      filters: flattenFilters(props.filters),
      suggestions: props.suggestions,
      search: props.search,
      options: props.options,
      sort: props.sort,
      resultsId: timestamp(),
    };

    if (canUseDOM) {
      this.history = createHistory();
    }
  }

  queryParams() {
    let { search, filters, options, sort } = this.state;
    return {search, sort, ...filters, ...options};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  pushState = () => {
    if (this.history) {
      this.history.push({search: `?${this.query()}`});
    }
  };

  onFiltersChange = (filters, count, suggestions) => {
    this.setState({filters, count, suggestions, resultsId: timestamp(), competitors: null});
    this.pushState();
  };

  onSearchChange = (search) => {
    this.setState({search});
  };

  onSort = (key, direction) => {
    const sort = replaceSort(key, direction, this.state.sort);
    this.setState({sort});
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
            <FilterRow
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
    const { options, suggestions } = this.state;
    return (
      <Switch
        name={name}
        value={options[name]}
        highlight={suggestions.includes(name)}
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
    const { competitors, count, sort, resultsId } = this.state;
    const source = {path: CompetitorsFilterPath, query: this.queryParams()};
    return (
      <div className="full-screen">
        <Results
          count={count}
          competitors={competitors}
          sort={sort}
          source={source}
          resultsId={resultsId}
          onSort={this.onSort}
        />
      </div>
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