import React from 'react';
import inflection from 'inflection';
import {extend, ffetch, storageKey, buildQuery} from '../global/utils';
import {
  CompetitorIndustriesOptions,
  CompetitorFundTypesOptions,
  InvestorsLocationsPath,
  CompaniesSearchPath,
  CompetitorsFilterCountPath,
  FilterPath,
} from '../global/constants.js.erb';
import Select from '../global/fields/select';
import Company from './company';
import {Link, Column, Row, Colors} from 'react-foundation';
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

  componentDidMount() {
    this.fetchNumInvestors(this.state.filters);
  }

  queryString(filters) {
    return buildQuery(_.mapValues(filters, f => _.map(f, 'value').join(',')));
  }

  fetchNumInvestors(filters) {
    let query = this.queryString(filters);
    if (!query) {
      return;
    }
    ffetch(`${CompetitorsFilterCountPath}?${query}`).then(resp => {
      this.setState({numInvestors: resp.count})
    })
  }

  onInputChange = (name, val) => {
    let inputs = extend(this.state.inputs, {[name]: val});
    this.setState({inputs});
  };

  onChange = (update) => {
    let filters = extend(this.state.filters, update);
    sessionStorage.setItem(SessionStorageKey, JSON.stringify(filters));
    this.setState({filters});
    this.fetchNumInvestors(filters);
  };

  selectProps(name, label) {
    let optionRenderer = o => <Highlighter
      highlightClassName='highlighter'
      searchWords={[this.state.inputs[name]]}
      textToHighlight={o.label}
    />;
    return {
      name: name,
      value: this.state.filters[name],
      placeholder: label,
      multi: true,
      optionRenderer,
      onInputChange: v => this.onInputChange(name, v),
      onChange: this.onChange,
    };
  }

  renderSelectWithProps(size, label, props) {
    let select = <Select {...props} />;
    if (this.props.showLabels) {
      select = (
        <label>
          <h6>{label}</h6>
          {select}
        </label>
      );
    }
    return (
      <Column large={size} className="filter-column">
        {select}
      </Column>
    );
  }

  renderSelect(name, label, options, size = 3) {
    return this.renderSelectWithProps(size, label, {options, ...this.selectProps(name, label)});
  }

  renderStaticRemoteSelect(name, label, path, size = 3) {
    let loadOptions = () => ffetch(path).then(options => ({options, complete: true}));
    let searchPromptText = "No results found";
    return this.renderSelectWithProps(size, label, {loadOptions, searchPromptText, ...this.selectProps(name, label)});
  }

  renderDynamicRemoteSelect(name, label, path, size = 3, OptionComponent = null) {
    let loadOptions = (q) => {
      if (!q) {
        return ffetch(`${path}`).then(options => ({options: (this.state.filters[name] || []).concat(options)}));
      } else {
        return ffetch(`${path}?${buildQuery({q})}`).then(options => ({options}));
      }
    };
    let props = this.selectProps(name, label);
    if (OptionComponent) {
      props.optionRenderer = o => <OptionComponent input={this.state.inputs[name]} {...o} />;
    }
    return this.renderSelectWithProps(size, label, {loadOptions, ...props});
  }

  numInvestors() {
    if (!this.state.numInvestors) {
      return null;
    }

    return this.state.numInvestors;
  }

  renderButton() {
    return (
      <Column large={2} className="filter-column">
        <div className="boxed">
          <Link color={Colors.SUCCESS} href={`${FilterPath}?${this.queryString(this.state.filters)}`}>
            Find {this.numInvestors()} {inflection.inflect('Investors', this.state.numInvestors)}
          </Link>
        </div>
      </Column>
    );
  }

  render() {
    let { showButton } = this.props;
    return (
      <div className="filters">
        <Row>
          {this.renderSelect('fund_type', 'Stage', CompetitorFundTypesOptions, 2)}
          {this.renderSelect('industry', 'Industries', CompetitorIndustriesOptions, 2)}
          {this.renderDynamicRemoteSelect('location', 'Cities', InvestorsLocationsPath, showButton ? 3 : 4)}
          {this.renderDynamicRemoteSelect('companies', 'Invested In', CompaniesSearchPath, showButton ? 3 : 4, Company)}
          {showButton ? this.renderButton() : null}
        </Row>
      </div>
    );
  }
}