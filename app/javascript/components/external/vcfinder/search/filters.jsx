import React from 'react';
import {extend, ffetch, storageKey} from '../utils';
import {CompetitorIndustriesOptions, InvestorsLocationsPath} from '../constants.js.erb';
import SavedChoice from '../saved_choice';
import Investors from '../investors';

const SessionStorageKey = storageKey('SearchFilters');

export default class SearchFilters extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      filters: JSON.parse(sessionStorage.getItem(SessionStorageKey)) || {},
    };
  }

  onChange = (update) => {
    let filters = extend(this.state.filters, update);
    sessionStorage.setItem(SessionStorageKey, JSON.stringify(filters));
    this.setState({filters});
  };

  savedChoiceProps(name) {
    return {
      name: name,
      value: this.state.filters[name],
      label: _.capitalize(name),
      multi: true,
      onChange: this.onChange,
    };
  }

  renderSavedChoice(name, options) {
    return <SavedChoice
      options={options}
      {...this.savedChoiceProps(name)}
    />
  }

  renderRemoteSavedChoice(name, path) {
    return <SavedChoice
      loadOptions={() => ffetch(path).then(options => ({options, complete: true}))}
      {...this.savedChoiceProps(name)}
    />
  }

  render() {
    return (
      <div className="float-center investor">
        {this.renderSavedChoice('industry', CompetitorIndustriesOptions)}
        {this.renderRemoteSavedChoice('location', InvestorsLocationsPath)}
        <Investors filters={this.state.filters} />
      </div>
    );
  }
}