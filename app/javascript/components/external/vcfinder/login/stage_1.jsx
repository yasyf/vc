import React from 'react';
import {CompetitorIndustries} from '../constants.js.erb';
import VCFinderLoginStage from './stage';

export default class VCFinderLoginStage1 extends VCFinderLoginStage {
  onChange = (change) => {
    return this.onCompanyChange({company: change})
  };

  onClick = () => {
    this.onChange({verified: true}).then(this.props.onNextStage);
  };

  renderBody() {
    let {company} = this.state.founder;
    return (
      <div className="float-center investor">
        <p>Tell us a bit about what you're working on! This helps us recommend investors for you.</p>
        {this.renderSavedText("What's your company called?", 'company', 'name')}
        {this.renderSavedTextArea(`What is ${company.name} working on?`, 'company', 'description')}
        {this.renderSavedChoice(`What areas does ${company.name} focus on?`, 'company', 'industry', CompetitorIndustries)}
        <div className="pad-top">
          <button type="button" className="button" onClick={this.onClick} disabled={!company['complete?']}>
            Next
          </button>
        </div>
      </div>
    );
  }
}