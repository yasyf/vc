import React from 'react';
import SavedText from '../saved_text';
import { CompetitorFundingSizes, CompetitorIndustries } from '../constants.js.erb';
import { isDRF, isMe, fullName } from '../utils'

export default class InvestorDRFComments extends React.Component {
  renderSavedText(label, name, id, value, transform = null, disable = false) {
    let onChange = transform ? _.flow([transform, this.props.onChange]) : this.props.onChange;
    return <SavedText
      key={`${name}-${id}`}
      name={name}
      value={value}
      label={label}
      onChange={onChange}
      disabled={disable}
    />
  }

  renderNotes(label, notes, transform = null) {
    let foundMe = false;
    let noteNodes = notes.map(note => {
      let me = isMe(note.founder);
      if (me) {
        foundMe = true;
      }
      return this.renderSavedText(fullName(note.founder), 'note', note.id, note.body, transform, !me);
    });

    if (!foundMe) {
      noteNodes.push(this.renderSavedText(fullName(gon.founder), 'note', -1, '', transform));
    }

    return (
      <label>
        <h6>{label}</h6>
        {noteNodes}
      </label>
    );
  }

  renderDRFComments() {
    let { notes, competitor } = this.props;
    return (
      <div>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderNotes('DRF Investor Comments', notes)}
          </div>
          <div className="large-6 cell">
            {this.renderNotes('DRF Fund Comments', competitor.notes, u => ({competitor: u}))}
          </div>
        </div>
        <hr />
      </div>
    );
  }

  render() {
    if (!isDRF())
      return null;
    return this.renderDRFComments();
  }
}