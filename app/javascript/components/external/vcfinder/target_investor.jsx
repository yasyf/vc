import moment from 'moment';
import React from 'react';
import classNames from 'classnames';
import SavedText from './saved_text';
import { CompetitorFundingSizes, CompetitorIndustries } from './constants.js.erb';
import {  extend } from './utils'
import InvestorHead from './investor/head';
import InvestorBody from './investor/body';

export default class TargetInvestor extends React.Component {
  changeStage(stage) {
    return () => this.props.onTargetChange(this.props.id, {stage});
  }

  onChange = (update) => {
    this.props.onTargetChange(this.props.id, update);
  };

  onInvestorChange = (update) => {
    this.onChange({investor: update});
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
      value={value || this.props[name]}
      label={label}
      onChange={this.onChange}
    />
  }

  renderButtons() {
    switch (this.props.stage) {
      case 'added':
        return (
          <div className="float-center text-center">
            {this.renderHollowButton('success', 'I heard back', 'waiting')}
            {this.renderHollowButton('warning', 'I need an intro!', 'intro')}
          </div>
        );
        break;
      case 'intro':
        return (
          <div className="float-center text-center">
            {this.renderHollowButton('success', 'I got an intro!', 'waiting')}
          </div>
        );
        break;
      case 'waiting':
        return (
          <div className="float-center text-center">
            {this.renderHollowButton('primary', 'I heard back', 'respond')}
            {this.renderHollowButton('success', "They're interested!", 'interested')}
            {this.renderHollowButton('alert', "They're not interested", 'pass')}
          </div>
        );
        break;
      case 'respond':
        return (
          <div className="float-center text-center">
            {this.renderHollowButton('primary', 'I responded', 'waiting')}
            {this.renderHollowButton('success', "They're interested!", 'interested')}
            {this.renderHollowButton('alert', "They're not interested", 'pass')}
          </div>
        );
        break;
      case 'interested':
        return (
          <div className="float-center text-center">
            {this.renderHollowButton('alert', "They're not interested anymore", 'pass')}
          </div>
        );
        break;
    }
  }

  renderSavedFields() {
    return (
      <div className="card-section card-section-multi">
        <div className="grid-x grid-margin-x investor-row">
          <div className="large-6 cell">
            {this.renderSavedText('Priority', 'tier')}
          </div>
          <div className="large-6 cell">
            {this.renderSavedText('Note', 'note')}
          </div>
        </div>
      </div>
    );
  }

  render() {
    let merged = extend(this.props.investor, this.props);

    let { last_response } = this.props;
    let ago = last_response ? moment(last_response).fromNow() : undefined;

    return (
      <div className="card float-center investor">
        <InvestorHead {...merged} badge={ago} onChange={this.onInvestorChange} />
        {this.renderSavedFields()}
        <InvestorBody {...merged} onChange={this.onInvestorChange} />
        <div className="card-section card-section-multi">
          {this.renderButtons()}
        </div>
      </div>
    );
  }
}