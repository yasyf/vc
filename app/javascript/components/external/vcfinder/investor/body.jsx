import React from 'react';
import { CompetitorFundingSizes, CompetitorIndustries } from '../constants.js.erb';
import InvestorFields from './fields';
import InvestorDRFComments from './drf_comments';

export default class InvestorBody extends React.Component {
  render() {
    return (
      <div className="card-section card-section-multi">
        <InvestorFields {...this.props} />
        <InvestorDRFComments {...this.props} />
      </div>
    );
  }
}