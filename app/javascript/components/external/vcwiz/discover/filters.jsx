import React from 'react';
import {extend, flattenFilters, withSeparators} from '../global/utils';
import {
  CompetitorFullIndustriesOptions,
  CompetitorFundTypesOptions,
  CompetitorsLocationsPath,
  CompaniesSearchPath,
} from '../global/constants.js.erb';
import {CookieStorage} from '../global/storage.js.erb';
import Company from './company';
import Filter from './filter';

const CookieStorageKey = 'filters';

export default class Filters extends React.Component {
  static defaultProps = {
    showLabels: true,
  };

  constructor(props) {
    super(props);

    this.state = {
      filters: this.props.initialFilters || {},
      inputs: {},
    };
  }

  onInputChange = (name, val) => {
    let inputs = extend(this.state.inputs, {[name]: val});
    this.setState({inputs});
  };

  onChange = (update) => {
    const filters = extend(this.state.filters, update);
    const flattened = flattenFilters(filters);
    CookieStorage.set(CookieStorageKey, flattened);
    this.setState({filters});
    this.props.onChange(flattened);
  };

  renderFilter(name, label, optionProps, showMeta = true) {
    if (this.props.fields && !this.props.fields.includes(name)) {
      return null;
    }
    return (
      <Filter
        key={name}
        name={name}
        label={label}
        input={this.state.inputs[name]}
        value={this.state.filters[name]}
        meta={showMeta ? this.props.meta : undefined}
        showLabel={this.props.showLabels}
        onInputChange={this.onInputChange}
        onChange={this.onChange}
        {...optionProps}
      />
    );
  }

  render() {
    const { onlyLocal } = this.props;
    const filters = _.compact([
      this.renderFilter('fund_type', 'Stage', { options: CompetitorFundTypesOptions }),
      this.renderFilter('industry', 'Industries', { options: CompetitorFullIndustriesOptions }),
      this.renderFilter('location', 'Cities', { path: CompetitorsLocationsPath }),
      this.renderFilter('companies', 'Related Startups', { path: CompaniesSearchPath, optionComponent: Company }, false),
    ]);
    return withSeparators(i => <hr key={`hr-${i}`} className="vr"/>, filters);
  }
}