import React from 'react';
import {buildQuery, ffetch} from '../global/utils';
import Filters from './filters';
import MoreFilters from './more_filters';

export default class FilterRow extends React.Component {
  static defaultProps = {
    onChange: _.noop,
    onButtonClick: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      numInvestors: props.initialCount,
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    return (
      nextState.numInvestors !== this.state.numInvestors
      || !_.isEqual(nextProps.filters, this.props.filters)
      || !_.isEqual(nextProps.options, this.props.options)
      || !_.isEqual(nextProps.suggestions, this.props.suggestions)
      || !_.isEqual(nextProps.countSource, this.props.countSource)
    )
  }

  componentDidUpdate(prevProps, prevState) {
    if (buildQuery(this.props.countSource.query) !== buildQuery(prevProps.countSource.query)) {
      this.fetchNumInvestors(this.props.filters)
    }
  }

  fetchNumInvestors(filters) {
    const {path, query} = this.props.countSource;
    let built = buildQuery({...query, ...filters});
    if (built) {
      ffetch(`${path}?${built}`).then(({count, suggestions}) => {
        this.setState({numInvestors: count, suggestions});
        this.props.onFiltersChange(filters, count, suggestions);
      });
    } else {
      ffetch(path).then(({count, suggestions}) => {
        this.setState({numInvestors: null, suggestions});
        this.props.onFiltersChange({}, count, suggestions);
      });
    }
  }

  onFiltersChange = filters => {
    if (_.isEqual(filters, this.props.filters)) {
      return;
    }
    this.fetchNumInvestors(filters);
  };

  meta() {
    if (!this.state.numInvestors) {
      return null;
    }
    return `Filter Results (${this.state.numInvestors})`;
  }

  render() {
    const { initialCount, countSource, onFiltersChange, onOptionChange, onButtonClick, options, suggestions, ...rest } = this.props;
    const filters = <Filters onChange={this.onFiltersChange} meta={this.meta()} {...rest} />;
    return (
      <div className="filters">
        <div className="filters-wrapper">
          {filters}
          <MoreFilters options={options} suggestions={suggestions} onChange={onOptionChange} />
        </div>
      </div>
    );
  }
}