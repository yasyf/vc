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
        <div className="search">
          <p>
            Type your name to find yourself in the VCWiz database, and continue to the investor portal.
            We are currently not accepting applications to be added to VCWiz.
          </p>
          <InvestorTypeahead onResult={this.onResult} />
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