import React from 'react';
import {InvestorsAddPath, InvestorsImpersonatePath} from '../constants.js.erb';
import SettingsBase from './settings_base';
import {Row, Column, Button, Colors} from 'react-foundation';
import {ffetch} from '../utils';
import StandardLoader from '../shared/standard_loader';

const RequiredFields = {
  first_name: 'First Name',
  last_name: 'Last Name',
  email: 'Email',
  role: 'Title',
  crunchbase_id: 'Crunchbase Profile',
};

export default class AddInvestor extends SettingsBase {
  constructor(props) {
    super(props);
    this.state = {
      ...this.state,
      data: {},
      error: null,
      investor: null,
    };
  }

  onClick = () => {
    ffetch(InvestorsAddPath, 'POST', {investor: this.state.data}).then(({investor, error}) => {
      if (error) {
        this.setState({error});
      } else if (investor) {
        this.setState({investor});
        setTimeout(() => { window.location.href = InvestorsImpersonatePath.id(investor.id); }, 10 * 1000);
      }
    });
  };

  missingInput() {
    for (let k in RequiredFields) {
      if (!this.state.data[k]) {
        return RequiredFields[k];
      }
    }
    return null;
  }

  renderError() {
    const { error, data } = this.state;
    if (!error) {
      return null;
    }
    return <p>{data.first_name} cannot be added because: <span className="error">{error}</span></p>;
  }

  render() {
    const { investor } = this.state;
    const { competitor } = this.props;
    const missing = this.missingInput();

    if (investor) {
      return (
        <div>
          <p>In a few moments, you'll be redirected to {investor.first_name}'s profile to complete it.</p>
          <StandardLoader />
        </div>
      );
    }

    return (
      <div className="fields">
        <p className="padded">Fill out these basic fields to add your coworker to VCWiz.</p>
        <Row>
          <Column large={6}>{this.renderInput('first_name', 'First Name')}</Column>
          <Column large={6}>{this.renderInput('last_name', 'Last Name')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('linkedin', 'LinkedIn Profile')}</Column>
          <Column large={6}>{this.renderInput('email', 'Email')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('role', `Title at ${competitor.name}`)}</Column>
          <Column large={6}>{this.renderInput('crunchbase_id', 'Crunchbase Profile')}</Column>
        </Row>
        <Row isColumn className="button-wrapper">
          {this.renderError()}
          <Button color={Colors.SUCCESS} onClick={this.onClick} isDisabled={!!missing}>
            {missing ? `${missing} is required!` : 'Submit'}
          </Button>
        </Row>
      </div>
    );
  }
}