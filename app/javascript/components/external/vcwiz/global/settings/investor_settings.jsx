import React from 'react';
import {ffetch, fullName} from '../utils';
import {CompetitorsLocationsPathWithQuery, InvestorsPath, CompaniesSearchPath, CompetitorFullIndustriesOptions, InvestorPath} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import SettingsBase from './settings_base';
import Company from '../../discover/company';

export default class InvestorSettings extends SettingsBase {
  constructor(props) {
    super(props);
    this.state.data = {
      ...props.investor,
      companies: props.companies,
      industries: props.industries,
    };
  }

  onBlur = name => () => {
    const investor = this.onBlurDirty(name);
    if (!investor) {
      return;
    }
    ffetch(InvestorsPath.id(this.props.investor.id), 'PATCH', {investor});
  };

  renderTop() {
    return <h3>Investor Profile: {fullName(this.props.investor)}</h3>;
  }

  renderBottom() {
    const competitor = this.props.investor.competitor;
    return (
      <div className="fields">
        <p className="info">
          These fields will be used to generate your VCWiz Investor Profile, which will be shown to founders.
          Please fill out the information specific to you, not {competitor.name} as a whole.
          This page will auto-save as you make changes.
          To view your external profile, click <a href={InvestorPath.id(this.props.investor.id)} target="_blank">here</a>.
        </p>
        <Row>
          <Column large={6}>{this.renderInput('first_name', 'First Name')}</Column>
          <Column large={6}>{this.renderInput('last_name', 'Last Name')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('linkedin', 'LinkedIn Username')}</Column>
          <Column large={6}>{this.renderInput('email', 'Email')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('role', `Title at ${competitor.name}`)}</Column>
          <Column large={6}>{this.renderInput('photo', 'Photo (URL)')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('homepage', 'Personal Homepage')}</Column>
          <Column large={6}>{this.renderAutoInput('location', 'City', CompetitorsLocationsPathWithQuery)}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('twitter', 'Twitter Username')}</Column>
          <Column large={6}>{this.renderInput('facebook', 'Facebook Username')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('al_username', 'AngelList ID')}</Column>
          <Column large={6}>{this.renderInput('crunchbase_id', 'Crunchbase ID')}</Column>
        </Row>
        <Row>
          <Column large={6}>
            {this.renderFilter('companies', `Your investments at ${competitor.name}`,  { path: CompaniesSearchPath, optionComponent: Company })}
          </Column>
          <Column large={6}>
            {this.renderFilter('industries', `Spaces you invest in`,  { options: CompetitorFullIndustriesOptions })}
          </Column>
        </Row>
        <Row isColumn>
          {this.renderTextArea('description', `Your biography and investment thesis`)}
        </Row>
      </div>
    );
  }

  render() {
    return this.props.render(this.renderTop(), this.renderBottom());
  }
}