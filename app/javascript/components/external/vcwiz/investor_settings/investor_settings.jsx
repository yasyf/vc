import React from 'react';
import VCWiz  from '../vcwiz';
import InvestorSettingsPage from '../global/settings/investor_settings';
import { InvestorsRootPath } from '../global/constants.js.erb';

export default class InvestorSettings extends React.Component {
  render() {
    const { investor } = this.props;
    return (
      <InvestorSettingsPage
        {...this.props}
        render={(top, bottom) => (
          <VCWiz
            page="investor_settings"
            subtitle={`${investor.competitor.name} Investor Portal`}
            header={top}
            body={bottom}
            showLogin={false}
            logoLinkPath={InvestorsRootPath}
          />
        )}
      />
    );
  }
}