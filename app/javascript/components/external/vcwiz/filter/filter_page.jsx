import React from 'react';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath, CompetitorsFilterCountPath, FilterTypes, CompaniesSearchPath} from '../global/constants.js.erb';
import {
  flattenFilters,
  buildQuery,
  ffetch,
  extend,
  timestamp,
  replaceSort,
} from '../global/utils';
import Search from '../discover/search';
import {Row} from 'react-foundation';
import FilterRow from '../discover/filter_row';
import Filters from '../discover/filters';

export default class FilterPage extends React.Component {
  static defaultProps = {
    onQueryChange: _.noop,
    applySuggestions: false,
  };

  constructor(props) {
    super(props);

    this.state = {
      canApplySuggestions: false,
      competitors: props.competitors,
      count: props.count,
      filters: flattenFilters(props.filters),
      suggestions: props.suggestions,
      search: props.search,
      options: props.options,
      sort: props.sort,
      columns: props.cols,
      resultsId: timestamp(),
    };
  }

  componentDidMount() {
    this.props.onQueryChange(this.query(), this.state.count);
  }

  queryParams(state = null) {
    const { applySuggestions, types } = this.props;
    let { search, filters, options, sort, canApplySuggestions } = state || this.state;
    const params = { options, sort, apply_suggestions: applySuggestions && canApplySuggestions };
    if (types === FilterTypes.SEARCH) {
      params.search = search;
    } else if (types === FilterTypes.FILTER) {
      params.filters = _.omit(filters, ['source_companies', 'entities']);
    } else if (types === FilterTypes.FILTER_ALL) {
      params.filters = _.omit(filters, ['source_companies']);
    } else if (types === FilterTypes.COMPANY) {
      params.filters = {companies: filters.source_companies};
      params.options = {};
      params.apply_suggestions = false;
    } else if (types === FilterTypes.ENTITY) {
      params.filters = _.pick(filters, ['entities']);
      params.options = {};
      params.apply_suggestions = false;
    }
    return params;
  }

  query() {
    return buildQuery(this.queryParams());
  }

  componentDidUpdate(prevProps, prevState) {
    if (
      this.state.resultsId === prevState.resultsId
      && (
        (this.props.types === FilterTypes.FILTER && prevProps.types !== FilterTypes.FILTER)
        || buildQuery(this.queryParams()) !== buildQuery(this.queryParams(prevState))
      )
    ) {
      this.fetchNumInvestors();
    }
  }

  fetchNumInvestors() {
    ffetch(`${CompetitorsFilterCountPath}?${this.query()}`).then(({count, cols, suggestions}) => {
      const newState = {count, suggestions, columns: cols, resultsId: timestamp(), competitors: null};
      if (this.props.applySuggestions && this.state.canApplySuggestions) {
        newState.options = suggestions;
        newState.canApplySuggestions = false;
      }
      this.setState(newState, () => this.props.onQueryChange(this.query(), count));
    });
  }

  onFiltersChange = filters => {
    this.setState({filters, canApplySuggestions: true});
  };

  onSearchChange = ({ search }) => {
    this.setState({search});
  };

  onCompaniesChange = filters => {
    this.setState({filters});
  };

  onEntitiesChange = filters => {
    this.setState({filters});
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
        onFiltersChange={this.onFiltersChange}
        onOptionChange={this.onOptionChange}
        fields={this.props.fields}
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

  renderCompany() {
    return (
      <div className="filters">
        <Filters
          fields={['source_companies']}
          onChange={this.onCompaniesChange}
        />
      </div>
    );
  }

  renderEntities() {
    return (
      <div className="filters">
        <Filters
          fields={['entities']}
          onChange={this.onEntitiesChange}
        />
      </div>
    );
  }

  renderSearchAndFilters() {
    const { types } = this.props;
    if (types === FilterTypes.FILTER || types === FilterTypes.FILTER_ALL) {
      return <Row isColumn>{this.renderFilterRow()}</Row>;
    } else if (types === FilterTypes.SEARCH) {
      return <Row isColumn>{this.renderSearch()}</Row>;
    } else if (types === FilterTypes.COMPANY) {
      return <Row isColumn>{this.renderCompany()}</Row>;
    } else if (types === FilterTypes.ENTITY) {
      return <Row isColumn>{this.renderEntities()}</Row>;
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
    const { competitors, count, sort, columns, resultsId } = this.state;
    const { rowHeight, industryLimit, fullHeight } = this.props;
    const source = {path: CompetitorsFilterPath, query: this.queryParams()};
    return (
      <Results
        count={count}
        competitors={competitors}
        sort={sort}
        source={source}
        resultsId={resultsId}
        columns={columns}
        rowHeight={rowHeight}
        industryLimit={industryLimit}
        fullHeight={fullHeight}
        onSort={this.onSort}
      />
    );
  }

  render() {
    return this.props.render(this.renderHeader(), this.renderBody());
  }
}