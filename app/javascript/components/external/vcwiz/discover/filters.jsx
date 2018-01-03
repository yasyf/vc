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

const defaultLabels = {
  fund_type: 'Stage',
  industry: 'Industries',
  location: 'Cities',
  companies: 'Related Startups',
  source_companies: 'Startups',
};

export default class Filters extends React.Component {
  static defaultProps = {
    showLabels: true,
    labels: {},
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
    CookieStorage.set(CookieStorageKey, _.omit(flattened, ['source_companies']));
    this.setState({filters});
    this.props.onChange(flattened);
  };

  renderFilter(name, optionProps, showMeta = true) {
    if (this.props.fields && !this.props.fields.includes(name)) {
      return null;
    }
    return (
      <Filter
        key={name}
        name={name}
        label={this.props.labels[name] || defaultLabels[name]}
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
    const filters = _.compact([
      this.renderFilter('fund_type', { options: CompetitorFundTypesOptions }),
      this.renderFilter('industry', { options: CompetitorFullIndustriesOptions }),
      this.renderFilter('location', { path: CompetitorsLocationsPath }),
      this.renderFilter('companies', { path: CompaniesSearchPath, optionComponent: Company }, false),
      this.renderFilter('source_companies', { path: CompaniesSearchPath, optionComponent: Company }),
    ]);
    return withSeparators(i => <hr key={`hr-${i}`} className="vr"/>, filters);
  }
}