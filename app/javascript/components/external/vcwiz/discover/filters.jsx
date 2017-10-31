import React from 'react';
import { extend, ffetch, buildQuery, flattenFilters } from '../global/utils';
import {
  CompetitorIndustriesOptions,
  CompetitorFundTypesOptions,
  CompetitorsLocationsPath,
  CompaniesSearchPath,
} from '../global/constants.js.erb';
import Storage from '../global/storage.js.erb';
import Select from '../global/fields/select';
import Company from './company';
import {Column, Row} from 'react-foundation';
import Highlighter from 'react-highlight-words';

const SessionStorageKey = 'Filters';

export default class Filters extends React.Component {
  static defaultProps = {
    showLabels: false,
    sizes: {
      fund_type: 2,
      industry: 2,
      location: 4,
      companies: 4,
    },
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

  selectProps(name, label) {
    let optionRenderer = o => <Highlighter
      highlightClassName='highlighter'
      searchWords={[this.state.inputs[name]]}
      textToHighlight={o.label}
    />;
    const value = this.state.filters[name];
    let showLabel = this.props.showLabels;
    if (showLabel === 'present') {
      showLabel = !_.isEmpty(value);
    }
    return {
      name: name,
      value: value,
      placeholder: label,
      showLabel: showLabel,
      multi: true,
      optionRenderer,
      onInputChange: v => this.onInputChange(name, v),
      onChange: this.onChange,
    };
  }

  renderSelectWithProps(label, props) {
    const size = this.props.sizes[props.name];
    if (!size) {
      return null;
    }
    const select = <Select {...props} />;
    if (size === -1) {
      return (
        <Row className="filter-row-column" key={props.name} isColumn>
          {select}
        </Row>
      );
    } else {
      return (
        <Column large={size} className="filter-column" key={props.name}>
          {select}
        </Column>
      );
    }
  }

  renderSelect(name, label, options) {
    return this.renderSelectWithProps(label, {options, ...this.selectProps(name, label)});
  }

  renderStaticRemoteSelect(name, label, path) {
    let loadOptions = () => ffetch(path).then(options => ({options, complete: true}));
    let searchPromptText = "No results found";
    return this.renderSelectWithProps(label, {loadOptions, searchPromptText, ...this.selectProps(name, label)});
  }

  renderDynamicRemoteSelect(name, label, path, OptionComponent = null) {
    let loadOptions = (q) => {
      if (!q) {
        return new Promise(cb => cb({options: this.state.filters[name] || []}));
      } else {
        return ffetch(`${path}?${buildQuery({q})}`).then(options => ({options}));
      }
    };
    let props = this.selectProps(name, label);
    if (OptionComponent) {
      props.optionRenderer = o => <OptionComponent input={this.state.inputs[name]} {...o} />;
    }
    return this.renderSelectWithProps(label, {loadOptions, ...props});
  }

  render() {
    const { onlyLocal } = this.props;
    const filters = [
      this.renderSelect('fund_type', 'Stage', CompetitorFundTypesOptions),
      this.renderSelect('industry', 'Industries', CompetitorIndustriesOptions),
      this.renderDynamicRemoteSelect('location', 'Cities', CompetitorsLocationsPath),
      this.renderDynamicRemoteSelect('companies', 'Related Startups', CompaniesSearchPath, Company),
    ];
    return <Row>{filters}</Row>;
  }
}