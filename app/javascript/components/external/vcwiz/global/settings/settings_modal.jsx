import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import {extend, ffetch} from '../utils';
import {FounderLocationsPath, FounderPath} from '../constants.js.erb';
import Store from '../store';
import Actions from '../actions';
import AutoInput from '../fields/auto_input';
import Input from '../fields/input';
import TextArea from '../fields/text_area';
import {Row, Column} from 'react-foundation';

export default class SettingsModal extends React.Component {
  static stateFromFounder = newFounder => {
    const founder = _.clone(newFounder);
    if (!founder.primary_company)
      founder.primary_company = {};
    return {founder};
  };

  constructor(props) {
    super(props);
    this.state = {
      dirty: {},
      ...SettingsModal.stateFromFounder(Store.get('founder', {})),
    };
  }

  componentWillMount() {
    this.subscription = Store.subscribe('founder', founder => this.setState(SettingsModal.stateFromFounder(founder)));
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  onChange = name => update => {
    const value = update[name];
    const founder = extend(this.state.founder, _.set({}, name, value));
    const dirty = extend(this.state.dirty, {[name]: true});
    this.setState({founder, dirty});
  };

  onBlur = name => () => {
    if (!this.state.dirty[name]) {
      return;
    }
    const value = _.get(this.state.founder, name);
    const founder = _.set({}, name, value || null);
    const dirty = extend(this.state.dirty, {[name]: false});
    this.setState({dirty});
    ffetch(FounderPath, 'PATCH', {founder}).then(newFounder => Actions.trigger('refreshFounder', newFounder));
  };

  renderTop() {
    return <h3>Your Settings</h3>;
  }

  inputProps(name, placeholder) {
    return {
      key: name,
      name: name,
      value: _.get(this.state.founder, name),
      placeholder: placeholder,
      showLabel: true,
      wrap: false,
      onBlur: this.onBlur(name),
      onChange: this.onChange(name),
    };
  }

  renderAutoInput(name, placeholder) {
    return <AutoInput {...this.inputProps(name, placeholder)} path={FounderLocationsPath} />;
  }

  renderInput(name, placeholder) {
    return <Input {...this.inputProps(name, placeholder)} />;
  }

  renderTextArea(name, placeholder) {
    return <TextArea {...this.inputProps(name, placeholder)} />;
  }

  renderBottom() {
    return (
      <div className="fields">
        <Row>
          <Column large={6}>{this.renderInput('homepage', 'Your Personal Homepage')}</Column>
          <Column large={6}>{this.renderAutoInput('city', 'Your City')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('twitter', 'Your Twitter Username')}</Column>
          <Column large={6}>{this.renderInput('linkedin', 'Your LinkedIn Username')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('primary_company.name', 'Company Name')}</Column>
          <Column large={6}>{this.renderInput('primary_company.domain', 'Company Domain')}</Column>
        </Row>
        <Row isColumn>
          {this.renderTextArea('primary_company.description', 'A short description that will help investors better understand your startup')}
        </Row>
      </div>
    );
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