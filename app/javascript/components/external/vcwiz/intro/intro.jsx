import React from 'react';
import VCWiz  from '../vcwiz';
import InvestorHeader from './investor_header';
import { InvestorsRootPath } from '../global/constants.js.erb';

export default class Intro extends React.Component {
  render() {
    const { bodyHtml, investor } = this.props;
    const body = <div className="investor-portal-body" dangerouslySetInnerHTML={{ __html: bodyHtml }} />;
    return (
      <VCWiz
        page="intro"
        subtitle={`${investor.competitor.name} Investor Portal`}
        header={<InvestorHeader {...this.props} />}
        body={body}
        showLogin={false}
        logoLinkPath={InvestorsRootPath}
      />
    );
  }
}