import React from 'react';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {
  flattenFilters,
  buildQuery,
  extend,
  timestamp,
  replaceSort,
} from '../global/utils';
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';
import Switch from '../global/fields/switch';
import FilterRow from '../discover/filter_row';
import SectionWithDims from '../global/shared/section_with_dims';

export default class FilterPage extends React.Component {
  static defaultProps = {
    onQueryChange: _.noop,
    showFilters: true,
    showSearch: true,
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
  }

  componentDidMount() {
    this.props.onQueryChange(this.query(), this.state.count);
  }

  queryParams() {
    let { search, filters, options, sort } = this.state;
    return {search, sort, ...filters, ...options};
  }

  query() {
    return buildQuery(this.queryParams());
  }

  onFiltersChange = (filters, count, suggestions) => {
    this.setState({filters, count, suggestions, resultsId: timestamp(), competitors: null});
    this.props.onQueryChange(this.query(), count);
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

  renderFilterRow() {
    return (
      <FilterRow
        showButton={false}
        onChange={this.onFiltersChange}
        initialFilters={this.props.filters}
        initialCount={this.props.count}
        countSource={{path: CompetitorsFilterCountPath, query: this.queryParams()}}
      />
    );
  }

  renderSearch() {
    return (
      <Search
        value={this.props.search}
        onChange={this.onSearchChange}
      />
    );
  }

  renderSearchAndFilters() {
    const { showFilters, showSearch } = this.props;
    if (showFilters && showSearch) {
      return (
        <Row>
          <Column large={9}>
            {this.renderFilterRow()}
          </Column>
          <Column large={3}>
            {this.renderSearch()}
          </Column>
        </Row>
      );
    } else if (showFilters) {
      return <Row isColumn>{this.renderFilterRow()}</Row>;
    } else if (showSearch) {
      return <Row isColumn>{this.renderSearch()}</Row>;
    } else {
      return null;
    }

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

  renderHeader() {
    return (
      <div>
        <Row className="wide-row search-and-filters">
          {this.renderSearchAndFilters()}
        </Row>
        <Row className="wide-row">
          {this.renderSwitches()}
        </Row>
      </div>
    );
  }

  renderBody() {
    const { competitors, count, sort, resultsId } = this.state;
    const { rowHeight, industryLimit, overflowY } = this.props;
    const source = {path: CompetitorsFilterPath, query: this.queryParams()};
    return (
        <SectionWithDims dimensionsKey="dimensions">
          <Results
            count={count}
            competitors={competitors}
            sort={sort}
            source={source}
            resultsId={resultsId}
            rowHeight={rowHeight}
            industryLimit={industryLimit}
            overflowY={overflowY}
            onSort={this.onSort}
          />
        </SectionWithDims>
    );
  }

  render() {
    return this.props.render(this.renderHeader(), this.renderBody());
  }
}