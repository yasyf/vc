import React from 'react';
import { extend, flattenFilters } from '../global/utils';
import {
  CompetitorIndustriesOptions,
  CompetitorFundTypesOptions,
  CompetitorsLocationsPath,
  CompaniesSearchPath,
} from '../global/constants.js.erb';
import Storage from '../global/storage.js.erb';
import Company from './company';
import Filter from './filter';

const SessionStorageKey = 'Filters';

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

  componentDidMount() {
    const filters = Storage.get(SessionStorageKey);
    if (_.isEmpty(this.state.filters) && !_.isEmpty(filters)) {
      this.setState({filters});
      this.propagateOnChange(filters);
    }
  }

  onInputChange = (name, val) => {
    let inputs = extend(this.state.inputs, {[name]: val});
    this.setState({inputs});
  };

  propagateOnChange = filters => {
    this.props.onChange(flattenFilters(filters));
  };

  onChange = (update) => {
    let filters = extend(this.state.filters, update);
    Storage.set(SessionStorageKey, filters);
    this.setState({filters});
    this.propagateOnChange(filters);
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
      this.renderFilter('industry', 'Industries', { options: CompetitorIndustriesOptions }),
      this.renderFilter('location', 'Cities', { path: CompetitorsLocationsPath }),
      this.renderFilter('companies', 'Related Startups', { path: CompaniesSearchPath, optionComponent: Company }, false),
    ]);
    const withDividers = _.flatMap(filters, (f, i) =>  {
      if (i === filters.length - 1) {
        return [f];
      } else {
        return [f, <hr key={`hr-${i}`} className="vr"/>]
      }
    });
    return <div className="filters-wrapper">{withDividers}</div>;
  }
}