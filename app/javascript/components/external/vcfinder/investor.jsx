import React from 'react';
import classNames from 'classnames';
import SavedText from './saved_text';
import SavedChoice from './saved_choice';
import { CompetitorFundingSizes } from './constants.js.erb';

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

  render() {
    let investor = this.props.target.investor;
    return (
      <div className="card float-center investor">
        <div className="card-divider">
          <strong>{investor.first_name} {investor.last_name}</strong>
          &nbsp;
          <em>({investor.role}{investor.role ? ', ' : ''}{investor.competitor.name})</em>
        </div>
        <div className="card-section">
          <p className="faded">
            {investor.competitor.description}
            {' '}
            {investor.description}
          </p>
          <div className="grid-x grid-margin-x investor-row">
            <div className="large-6 cell">
              {this.renderSavedChoice('Industry', 'industry', CompetitorIndustries, true, investor.industry || investor.competitor.industry)}
            </div>
            <div className="large-6 cell">
              {this.renderSavedChoice('Check Size', 'funding_size', CompetitorFundingSizes, investor.competitor.funding_size)}
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
          <div className="float-center text-center">
            {this.renderButtons()}
          </div>
        </div>
      </div>
    );
  }
}