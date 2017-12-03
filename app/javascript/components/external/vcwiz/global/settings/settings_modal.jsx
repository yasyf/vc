import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import {extend, ffetch} from '../utils';
import {FounderLocationsPath} from '../constants.js.erb';
import Store from '../store';
import AutoInput from '../fields/auto_input';

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

  onChange = name => value => {
    const settings = extend(this.state.settings, {[name]: value});
    this.setState({settings});
  };

  renderTop() {
    return <h3>Your Settings</h3>;
  }

  renderInput(name, placeholder) {
    return (
      <AutoInput
        key={name}
        name={name}
        value={this.state.settings[name]}
        path={FounderLocationsPath}
        placeholder={placeholder}
        showLabel={true}
        wrap={false}
        onChange={this.onChange(name)}
      />
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