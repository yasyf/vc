import React from 'react';
import {CompetitorIndustries, CompetitorFundingSizes} from '../constants.js.erb';
import VCFinderLoginStage from './stage';

export default class VCFinderLoginStage2 extends VCFinderLoginStage {
  onChange = (change) => {
    this.onCompanyChange({investor_profile: change})
  };

  renderBody() {
    let { investor_profile } = this.state.founder;
    return (
      <div className="float-center investor">
        <p>Great! Anything else you're looking for specifically in your ideal investor?</p>
        {this.renderSavedText("Which city are they located in?", 'investor_profile', 'city')}
        {this.renderSavedChoice(`What is their average check size?`, 'investor_profile', 'funding_size', CompetitorFundingSizes, false)}
        <div className="pad-top">
          <button type="button" className="button" onClick={this.props.onNextStage}>
            {investor_profile['complete?'] ? 'Next' : 'Skip'}
          </button>
        </div>
      </div>
    );
  }
}