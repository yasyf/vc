import React from 'react';
import Filters from './filters';
import MoreFilters from './more_filters';

export default class FilterRow extends React.Component {
  shouldComponentUpdate(nextProps, nextState) {
    return (
      nextProps.initialCount !== this.props.initialCount
      || !_.isEqual(nextProps.filters, this.props.filters)
      || !_.isEqual(nextProps.options, this.props.options)
      || !_.isEqual(nextProps.suggestions, this.props.suggestions)
    )
  }

  onFiltersChange = filters => {
    if (_.isEqual(filters, this.props.filters)) {
      return;
    }
    this.props.onFiltersChange(filters);
  };

  meta() {
    if (!this.props.initialCount) {
      return null;
    }
    return `Filter Results (${this.props.initialCount})`;
  }

  render() {
    const { initialCount, onFiltersChange, onOptionChange, onButtonClick, options, suggestions, ...rest } = this.props;
    const filters = <Filters onChange={this.onFiltersChange} meta={this.meta()} fields={['fund_type', 'industry', 'location', 'companies']} {...rest} />;
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