import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import Input from '../fields/input';
import Filters from '../../discover/filters';
import {extend} from '../utils';
import {SignupPath} from '../constants.js.erb';
import {Button, Row, Colors} from 'react-foundation';
import HiddenForm from './hidden_form';

const RequiredFields = {
  0: ['name', 'description', 'industry'],
  1: ['fund_type', 'location'],
  2: [],
};
const NumStages = Object.keys(RequiredFields).length;

export default class LoginModal extends React.Component {
  state = {
    data: {},
    stage: 0,
  };

  onChange = update => {
    const data = extend(this.state.data, update);
    this.setState({data});
  };

  nextStage = () => {
    this.setState({stage: this.state.stage + 1});
  };

  loginWithGoogle= () => {
    this.form.submit();
  };

  renderTop() {
    return (
      <div>
        <h3 className="title">Sign Up For VCWiz</h3>
        <div className="muted title">
          Help us personalize your search results and provide you with introductions to VCs.
        </div>
      </div>
    );
  }

  renderInput(name, placeholder) {
    return (
      <Row key={name} isColumn>
        <Input
          name={name}
          placeholder={placeholder}
          value={this.state.value}
          onChange={this.onChange}
        />
      </Row>
    );
  }

  renderFilters(sizes) {
    return (
      <Filters
        key="filters"
        showButton={false}
        showLabels={'present'}
        sizes={sizes}
        onChange={this.onChange}
      />
    );
  }

  renderStage0() {
    return [
      <p className="info" key="text">Your Startup</p>,
      this.renderInput('name', 'Company Name'),
      this.renderInput('description', 'Description (may be shown to investors)'),
      this.renderInput('domain', 'Domain'),
      this.renderFilters({industry: -1, companies: -1}),
    ];
  }

  renderStage1() {
    return [
      <p className="info" key="text">Your Ideal Investor</p>,
      this.renderFilters({fund_type: -1, location: -1}),
    ];
  }

  renderStage2() {
    return [
      <p className="info" key="text">Login with your company email address to secure your account</p>,
      <HiddenForm key="form" data={this.state.data} formRef={form => { this.form = form; }} path={SignupPath} />,
    ];
  }

  renderButton() {
    if (this.state.stage === NumStages - 1) {
      return (
        <Button color={Colors.SUCCESS} onClick={this.loginWithGoogle}>
          Login with Google
        </Button>
      );
    }
    const enabled = _.every(_.map(RequiredFields[this.state.stage], f => this.state.data[f]), Boolean);
    return (
      <Row isColumn>
        <Button color={Colors.SUCCESS} onClick={enabled ? this.nextStage : undefined} isDisabled={!enabled}>
          Continue to Step {this.state.stage + 2} of {NumStages}
        </Button>
      </Row>
    );
  }

  renderBottom() {
    return (
      <div className="filters">
        <Row>
          {this[`renderStage${this.state.stage}`]()}
          {this.renderButton()}
        </Row>
      </div>
    )
  }

  render() {
    return (
      <OverlayModal
        name="login"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}