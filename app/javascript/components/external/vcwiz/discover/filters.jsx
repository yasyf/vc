import React from 'react';
import {extend, ffetch, storageKey, buildQuery} from '../global/utils';
import {
  CompetitorIndustriesOptions,
  CompetitorFundTypesOptions,
  InvestorsLocationsPath,
  CompaniesSearchPath,
} from '../global/constants.js.erb';
import Select from '../global/fields/select';
import Company from './company';
import {Column, Row} from 'react-foundation';
import Highlighter from 'react-highlight-words';

const SessionStorageKey = storageKey('Filters');

export default class Filters extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      filters: JSON.parse(sessionStorage.getItem(SessionStorageKey)) || {},
      inputs: {},
    };
  }

  onInputChange = (name, val) => {
    let inputs = extend(this.state.inputs, {[name]: val});
    this.setState({inputs});
  };

  onChange = (update) => {
    let filters = extend(this.state.filters, update);
    sessionStorage.setItem(SessionStorageKey, JSON.stringify(filters));
    this.setState({filters});
  };

  selectProps(name) {
    let optionRenderer = o => <Highlighter
      highlightClassName='highlighter'
      searchWords={[this.state.inputs[name]]}
      textToHighlight={o.label}
    />;
    return {
      name: name,
      value: this.state.filters[name],
      placeholder: _.capitalize(name),
      multi: true,
      optionRenderer,
      onInputChange: v => this.onInputChange(name, v),
      onChange: this.onChange,
    };
  }

  renderSelect(name, options, size = 3) {
    return (
      <Column large={size} className="filter-column">
        <Select
          options={options}
          {...this.selectProps(name)}
        />
      </Column>
    );
  }

  renderStaticRemoteSelect(name, path, size = 3) {
    return (
      <Column large={size} className="filter-column">
        <Select
          loadOptions={() => ffetch(path).then(options => ({options, complete: true}))}
          searchPromptText="No results found"
          {...this.selectProps(name)}
        />
      </Column>
    );
  }

  renderDynamicRemoteSelect(name, path, size = 3, OptionComponent = null) {
    let load = (q, cb) => {
      if (!q) {
        cb(null, {options: this.state.filters[name]});
      } else {
        return ffetch(`${path}?${buildQuery({q})}`).then(options => ({options}));
      }
    };
    let props = this.selectProps(name);
    if (OptionComponent) {
      props.optionRenderer = o => <OptionComponent input={this.state.inputs[name]} {...o} />;
    }
    return (
      <Column large={size} className="filter-column">
        <Select
          loadOptions={load}
          {...props}
        />
      </Column>
    );
  }

  render() {
    return (
      <div className="float-center investor">
        <Row>
          {this.renderSelect('fund_type', CompetitorFundTypesOptions, 2)}
          {this.renderSelect('industry', CompetitorIndustriesOptions, 2)}
          {this.renderStaticRemoteSelect('location', InvestorsLocationsPath, 3)}
          {this.renderDynamicRemoteSelect('companies', CompaniesSearchPath, 5, Company)}
        </Row>
      </div>
    );
  }
}