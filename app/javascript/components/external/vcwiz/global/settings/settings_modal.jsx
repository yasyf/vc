import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import Input from '../fields/input';
import Filters from '../../discover/filters';
import {extend} from '../utils';
import {SignupPath, LoginPath, CompaniesQueryPath, StorageRestoreStateKey} from '../constants.js.erb';
import Store from '../store';

export default class SettingsModal extends React.Component {
  constructor(props) {
    super(props);

    const { city } = Store.get('founder', {});

    this.state = {
      settings: {
        city,
      },
    };
  }

  onChange = update => {
    const settings = extend(this.state.settings, update);
    this.setState({settings});
  };

  renderTop() {
    return <h3>Your Settings</h3>;
  }

  renderInput(name, placeholder) {
    return (
      <Input
        key={name}
        name={name}
        placeholder={placeholder}
        value={this.state.settings[name]}
        wrap={false}
        onChange={this.onChange}
      />
    );
  }

  renderFilters(fields) {
    return (
      <div key="filters" className="filters">
        <div className="filters-wrapper">
          <Filters
            showButton={false}
            fields={fields}
            onChange={this.onChange}
          />
        </div>
      </div>
    );
  }

  renderBottom() {
    return [
      this.renderInput('city', 'City'),
    ];
  }

  render() {
    return (
      <OverlayModal
        name="settings"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}