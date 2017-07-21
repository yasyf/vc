import React from 'react';
import SavedChoice from '../saved_choice';
import { CompetitorFundingSizes, CompetitorIndustries } from '../constants.js.erb';
import { merge } from '../utils';

export default class InvestorFields extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      merged: merge(this.props, this.props.competitor),
    };
  }

  componentWillReceiveProps(newProps) {
    this.setState({merged: merge(newProps, newProps.competitor)});
  }

  renderSavedChoice(label, name, options, multi = false) {
    return <SavedChoice
      name={name}
      value={this.state.merged[name]}
      label={label}
      options={options}
      multi={multi}
      onChange={this.props.onChange}
      readonly={this.props.readonly}
    />
  }

  renderSavedFields() {
    return (
      <div>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedChoice('Industry', 'industry', CompetitorIndustries, true)}
          </div>
          <div className="large-6 cell">
            {this.renderSavedChoice('Check Size', 'funding_size', CompetitorFundingSizes)}
          </div>
        </div>
      </div>
    );
  }

  render() {
    return this.renderSavedFields();
  }
}