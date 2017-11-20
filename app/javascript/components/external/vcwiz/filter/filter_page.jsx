import React from 'react';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import {
  flattenFilters,
  buildQuery,
  ffetch,
  extend,
  timestamp,
  replaceSort,
} from '../global/utils';
import Search from '../discover/search';
import {Row, Column} from 'react-foundation';
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

  queryParams(state = null) {
    let { search, filters, options, sort } = state || this.state;
    const params = { options, sort };
    if (this.props.showSearch) {
      params.search = search;
    }
    if (this.props.showFilters) {
      params.filters = filters;
    }
    return params;
  }

  query() {
    return buildQuery(this.queryParams());
  }

  componentDidUpdate(prevProps, prevState) {
    if (
      (prevProps.showFilters !== this.props.showFilters && !_.isEmpty(_.compact(this.props.filters)))
      || (prevProps.showSearch !== this.props.showSearch && !_.isEmpty(_.compact(this.props.search)))
      || buildQuery(this.queryParams()) !== buildQuery(this.queryParams(prevState))
    ) {
      this.fetchNumInvestors();
    }
  }

  fetchNumInvestors() {
    const query = this.query();
    ffetch(`${CompetitorsFilterCountPath}?${query}`).then(({count, suggestions}) => {
      this.setState({count, suggestions, resultsId: timestamp(), competitors: null});
      this.props.onQueryChange(query, count);
    });
  }

  onFiltersChange = filters => {
    this.setState({filters});
  };

  onSearchChange = update => {
    let search = extend(this.state.search, update);
    this.setState({search});
  };

  onSort = (key, direction) => {
    const sort = replaceSort(key, direction, this.state.sort);
    this.setState({sort});
  };

  onOptionChange = update => {
    let options = extend(this.state.options, update);
    this.setState({options});
  };

  renderFilterRow() {
    return (
      <FilterRow
        overwriteWithSaved={this.props.overwriteWithSavedFilters}
        onFiltersChange={this.onFiltersChange}
        onOptionChange={this.onOptionChange}
        initialFilters={this.props.filters}
        filters={this.state.filters}
        options={this.state.options}
        initialCount={this.state.count}
        suggestions={this.state.suggestions}
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

  renderHeader() {
    return (
      <div>
        <h3>{this.props.title}</h3>
        <Row className="wide-row search-and-filters">
          {this.renderSearchAndFilters()}
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