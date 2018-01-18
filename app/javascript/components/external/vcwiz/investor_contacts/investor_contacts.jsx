import React from 'react';
import VCWiz  from '../vcwiz';
import SettingsBase from '../global/settings/settings_base';
import { InvestorsRootPath, InvestorsUpdateContactsPath } from '../global/constants.js.erb';
import { Row, Column, Button, Colors } from 'react-foundation';
import HiddenForm from '../global/login/hidden_form';
import ProfileImage from '../global/shared/profile_image';
import {fullName, initials} from '../global/utils';

export default class InvestorSettings extends SettingsBase {
  static defaultProps = {
    showLabels: false,
  };

  onSubmit = () => {
    this.form.submit();
  };

  renderTop() {
    return <h3>Other Investors at {this.props.investor.competitor.name}</h3>;
  }

  renderInvestor = (investor) => {
    const { competitor } = this.props.investor;
    const { photo, id, role } = investor;
    return (
      <Row key={id.toString()}>
        <Column large={7}>
          <ProfileImage transparency="E9E9E9" fallback={initials(investor)} src={photo || competitor.photo} size={50} className="inline-image" />
          <span>{fullName(investor)} {role ? `(${role})` : ''}</span>
        </Column>
        <Column large={5}>
          {this.renderInput(id.toString(), `${investor.first_name}'s ${competitor.domain} email`)}
        </Column>
      </Row>
    );
  };

  renderBottom() {
    const { investor, contacts } = this.props;
    return (
      <div className="fields">
        <p className="info">
          To present the most accurate information about {investor.competitor.name} to founders, you can invite your colleagues to verify their VCWiz profiles.
        </p>
        <HiddenForm data={{emails: JSON.stringify(this.state.data)}} formRef={form => { this.form = form; }} path={InvestorsUpdateContactsPath} />
        <div className="contacts">{contacts.map(this.renderInvestor)}</div>
        <Row isColumn className="button-wrapper">
          <Button onClick={this.onSubmit} color={Colors.SUCCESS}>
            {_.isEmpty(this.state.data) ? 'Skip' : 'Next'}
          </Button>
        </Row>
      </div>
    );
  }

  render() {
    return (
      <VCWiz
        page="investor_contacts"
        subtitle={`${this.props.investor.competitor.name} Investor Portal`}
        header={this.renderTop()}
        body={this.renderBottom()}
        showLogin={false}
        logoLinkPath={InvestorsRootPath}
      />
    );
  }
}
