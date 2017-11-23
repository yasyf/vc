import React from 'react';
import VCWiz  from '../vcwiz';
import InvestorHeader from './investor_header';

export default class Investor extends React.Component {
  render() {
    const { bodyHtml, investor } = this.props;
    const body = <div className="investor-portal-body" dangerouslySetInnerHTML={{ __html: bodyHtml }} />;
    return (
      <VCWiz
        page="investor"
        subtitle={`${investor.competitor.name} Investor Portal`}
        header={<InvestorHeader {...this.props} />}
        body={body}
        showLogin={false}
      />
    );
  }
}