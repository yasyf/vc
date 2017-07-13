import React from 'react';
import classNames from 'classnames';
import SavedText from './saved_text';
import SavedTextArea from './saved_text_area';
import SavedChoice from './saved_choice';
import { CompetitorFundingSizes, CompetitorIndustries } from './constants.js.erb';
import { isDRF } from './utils'

export default class Investor extends React.Component {
  changeStage(stage) {
    return () => this.props.onTargetChange(this.props.target.id, {stage});
  }

  onChange = (update) => {
    this.props.onTargetChange(this.props.target.id, update);
  };

  renderHollowButton(colour, text, newStage) {
    return (
      <span className="hollowButton">
      <button
        type="button"
        className={classNames('hollow', colour, 'button')}
        onClick={this.changeStage(newStage)}
      >
        {text}
       </button>
    </span>
    );
  }

  renderSavedText(label, name, value = null) {
    return <SavedText
      name={name}
      value={value || this.props.target[name]}
      label={label}
      onChange={this.onChange}
    />
  }

  renderSavedTextArea(label, name, value, transform) {
    return <SavedTextArea
      name={name}
      value={value}
      label={label}
      onChange={_.flow([transform, this.onChange])}
    />
  }

  renderSavedChoice(label, name, options, multi = false, value = null) {
    return <SavedChoice
      name={name}
      value={value || this.props.target[name]}
      label={label}
      options={options}
      multi={multi}
      joinValues={true}
      clearable={false}
      onChange={this.onChange}
    />
  }

  renderButtons() {
    switch (this.props.target.stage) {
      case 'added':
        return (
          <div>
            {this.renderHollowButton('success', 'I heard back', 'waiting')}
            {this.renderHollowButton('warning', 'I need an intro!', 'intro')}
          </div>
        );
        break;
      case 'intro':
        return (
          <div>
            {this.renderHollowButton('success', 'I got an intro!', 'waiting')}
          </div>
        );
        break;
      case 'waiting':
        return (
          <div>
            {this.renderHollowButton('primary', 'I heard back', 'respond')}
            {this.renderHollowButton('success', "They're interested!", 'interested')}
            {this.renderHollowButton('alert', "They're not interested", 'pass')}
          </div>
        );
        break;
      case 'respond':
        return (
          <div>
            {this.renderHollowButton('primary', 'I responded', 'waiting')}
            {this.renderHollowButton('success', "They're interested!", 'interested')}
            {this.renderHollowButton('alert', "They're not interested", 'pass')}
          </div>
        );
        break;
      case 'interested':
        return (
          <div>
            {this.renderHollowButton('alert', "They're not interested anymore", 'pass')}
          </div>
        );
        break;
    }
  }

  renderSavedFields() {
    let { investor } = this.props.target;
    let { competitor } = investor;
    return (
      <div>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedChoice('Industry', 'industry', CompetitorIndustries, true, investor.industry || competitor.industry)}
          </div>
          <div className="large-6 cell">
            {this.renderSavedChoice('Check Size', 'funding_size', CompetitorFundingSizes, competitor.funding_size)}
          </div>
        </div>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedText('Tier', 'tier')}
          </div>
          <div className="large-6 cell">
            {this.renderSavedText('Note', 'note')}
          </div>
        </div>
        {isDRF() ? this.renderDRFComments() : ''}
      </div>
    );
  }

  renderDRFComments() {
    let { investor } = this.props.target;
    let { competitor } = investor;
    return (
      <div>
        <h4>Private DRF Comments</h4>
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedTextArea('Investor', 'comments', investor.comments, u => ({investor: u}))}
          </div>
          <div className="large-6 cell">
            {this.renderSavedTextArea('Fund', 'comments', competitor.comments, u => ({investor: { competitor: u}}))}
          </div>
        </div>
      </div>
    );
  }

  render() {
    let { investor } = this.props.target;
    let { competitor } = investor;
    return (
      <div className="card float-center investor">
        <div className="card-divider">
          <strong>{investor.first_name} {investor.last_name}</strong>
          &nbsp;
          <em>({investor.role}{investor.role ? ', ' : ''}{competitor.name})</em>
        </div>
        <div className="card-section">
          <p className="faded">
            {competitor.description}
            {' '}
            {investor.description}
          </p>
          {this.renderSavedFields()}
          <div className="float-center text-center">
            {this.renderButtons()}
          </div>
        </div>
      </div>
    );
  }
}