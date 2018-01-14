import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import {ffetch} from '../utils';
import { FounderLocationsPath, FounderPath, LogoutPath } from '../constants.js.erb';
import Store from '../store';
import Actions from '../actions';
import {Row, Column, Colors, Button} from 'react-foundation';
import SettingsBase from './settings_base';
import hasModalErrorBoundary from '../shared/has_modal_error_boundary';

@hasModalErrorBoundary
export default class FounderSettingsModal extends SettingsBase {
  static stateFromFounder = newFounder => {
    const founder = _.clone(newFounder);
    if (!founder.primary_company)
      founder.primary_company = {};
    return {data: founder};
  };

  constructor(props) {
    super(props);
    this.state = {
      ...this.state,
      ...FounderSettingsModal.stateFromFounder(Store.get('founder', {})),
    };
  }

  componentWillMount() {
    this.subscription = Store.subscribe('founder', founder => this.setState(FounderSettingsModal.stateFromFounder(founder)));
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  pushFounder = founder => {
    ffetch(FounderPath, 'PATCH', {founder}).then(newFounder => Actions.trigger('refreshFounder', newFounder));
  };

  goToLogout = () => {
    window.location.href = LogoutPath;
  };

  toggleSubscription = () => {
    this.pushFounder({unsubscribed: !this.state.data.unsubscribed});
  };

  onBlur = name => () => {
    const founder = this.onBlurDirty(name);
    if (!founder) {
      return;
    }
    this.pushFounder(founder);
  };

  renderUnsubscribeButton() {
    return (
      <Button color={this.state.data.unsubscribed ? Colors.SUCCESS : Colors.ALERT} onClick={this.toggleSubscription}>
        {this.state.data.unsubscribed ? 'Enable' : 'Disable'} Weekly Summaries
      </Button>
    );
  }

  renderLogoutButton() {
    return (
      <Button color={Colors.ALERT} onClick={this.goToLogout}>
        Logout {this.state.data.email}
      </Button>
    );
  }

  renderTop() {
    return <h3>My Info</h3>;
  }

  renderBottom() {
    return (
      <div className="fields">
        <p>
          You can customize the information that will be shown to investors on your behalf.
          These fields will be only be used to generate VCWiz intro requests when you request them!
          If there's anything you'd prefer an investor not see, make sure you clear it out below.
        </p>
        <Row className="buttons">
          <Column large={6}>{this.renderUnsubscribeButton()}</Column>
          <Column large={6}>{this.renderLogoutButton()}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('homepage', 'Your Personal Homepage')}</Column>
          <Column large={6}>{this.renderAutoInput('city', 'Your City', FounderLocationsPath)}</Column>
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