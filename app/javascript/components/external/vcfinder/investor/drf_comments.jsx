import React from 'react';
import SavedTextArea from '../saved_text_area';
import { CompetitorFundingSizes, CompetitorIndustries } from '../constants.js.erb';
import { isDRF } from '../utils'

export default class InvestorDRFComments extends React.Component {
  renderSavedTextArea(label, name, value, transform = null) {
    let onChange = transform ? _.flow([transform, this.props.onChange]) : this.props.onChange;
    return <SavedTextArea
      name={name}
      value={value}
      label={label}
      onChange={onChange}
    />
  }

  renderDRFComments() {
    let { comments, competitor } = this.props;
    return (
      <div>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedTextArea('DRF Investor Comments', 'comments', comments)}
          </div>
          <div className="large-6 cell">
            {this.renderSavedTextArea('DRF Fund Comments', 'comments', competitor.comments, u => ({competitor: u}))}
          </div>
        </div>
      </div>
    );
  }

  render() {
    if (!isDRF())
      return null;
    return this.renderDRFComments();
  }
}