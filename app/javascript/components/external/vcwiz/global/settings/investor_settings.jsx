import React from 'react';
import {doNotPropagate, ffetch, fullName} from '../utils';
import {
  CompetitorsLocationsPathWithQuery,
  InvestorsPath,
  CompaniesSearchPath,
  CompetitorFullIndustriesOptions,
  InvestorPath,
  CCEmail,
  InvestorsImpersonatePath, DiscoverPath,
} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import SettingsBase from './settings_base';
import Company from '../../discover/company';
import Partner from '../../investor_contacts/partner';
import Tabs from '../tabs/tabs';
import AddInvestor from './add_investor';

export default class InvestorSettings extends SettingsBase {
  constructor(props) {
    super(props);
    this.state = {
      ...this.state,
      data: {
        ...props.investor,
        companies: props.companies,
        industries: props.industries,
      },
      partners: props.partners,
    };
  }

  onBlur = name => () => {
    const investor = this.onBlurDirty(name);
    if (!investor) {
      return;
    }
    ffetch(InvestorsPath.id(this.props.investor.id), 'PATCH', {investor});
  };

  onRemove = id => e => {
    doNotPropagate(e);
    ffetch(InvestorsPath.id(id), 'PATCH', {investor: {hidden: true}});
    this.setState({partners: _.reject(this.state.partners, {id})});
  };

  impersonate = id => () => {
    window.location.href = InvestorsImpersonatePath.id(id);
  };

  renderTop() {
    return <h3>Investor Portal: {fullName(this.props.investor)}</h3>;
  }

  renderInvestorProfile() {
    const competitor = this.props.investor.competitor;
    return (
      <div className="fields">
        <p className="info padded">
          These fields will be used to generate your VCWiz Investor Profile, which will be shown to founders.
          To view your external profile, click <a href={InvestorPath.id(this.props.investor.id)} target="_blank">here</a>.
          All communication with founders occurs over email—make sure to add <b>{CCEmail}</b> to your address book!
        </p>
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

  renderInvestor = investor => {
    const { competitor } = this.props.investor;
    const { id } = investor;
    return <Partner key={id.toString()} onClick={this.impersonate(id)} investor={investor} competitor={competitor} onRemove={this.onRemove} showRole={false} />;
  };

  renderOthers() {
    const { competitor } = this.props.investor;
    const { partners } = this.state;
    return (
      <div className="fields">
        <p className="info padded">
          These are the other investors at {competitor.name} that VCWiz knows about.
          Please help us remove people who have left the firm.
          You can also fill in the profile information for any of your coworkers, by clicking on their name.
        </p>
        <div className="contacts">{partners.map(this.renderInvestor)}</div>
      </div>
    );
  }



  renderBottom() {
    const { competitor } = this.props.investor;
    return (
      <div className="full-width">
        <p>Welcome to your VCWiz investor portal. This page will auto-save as you make changes!</p>
        <Tabs
          tabs={[
            "Edit Your Profile",
            "Manage Coworkers",
            "Add a Coworker",
          ]}
          panels={[
            this.renderInvestorProfile(),
            this.renderOthers(),
            <AddInvestor competitor={competitor} />,
          ]}
        />
      </div>
    )
  }

  render() {
    return this.props.render(this.renderTop(), this.renderBottom());
  }
}