import React from 'react';
import VCWiz  from '../vcwiz';
import InvestorTypeahead from '../outreach/investor_typeahead';
import InvestorVerification from './investor_verification';
import { InvestorsRootPath } from '../global/constants.js.erb';

export default class InvestorSignup extends React.Component {
  state = {
    id: null
  };

  onResult = ({investor}) => {
    this.setState({id: investor.id});
  };

  renderTop() {
    return <h3>Investor Portal Login</h3>
  }

  renderBottom() {
    const { id } = this.state;
    if (id) {
      return <InvestorVerification id={id} />;
    } else {
      return (
        <div>
          <p>
            VCWiz is a tool for founders to research investors, discover new firms, and manage their fundraising outreach.
            As an investor, you have an automatically-generated profile on VCWiz.
            By claiming your account below, you can ensure founders get the most up-to-date information on you and your firm.
          </p>
          <div className="search">
            <p>
              Type your name to find yourself in the VCWiz database, and continue to the investor portal.
            </p>
            <InvestorTypeahead onResult={this.onResult} />
          </div>
        </div>
      );
    }
  }

  render() {
    return (
      <VCWiz
        page="investor_signup"
        subtitle="Investor Portal"
        header={this.renderTop()}
        body={this.renderBottom()}
        showLogin={false}
        logoLinkPath={InvestorsRootPath}
      />
    );
  }
}
