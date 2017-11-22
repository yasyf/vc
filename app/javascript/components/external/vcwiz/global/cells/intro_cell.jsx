import React from 'react';
import {UnpureTextCell} from './text_cell';
import IconLine from '../shared/icon_line';
import Store from '../store';
import {TargetInvestorStagesKeys} from '../constants.js.erb';

export default class IntroCell extends UnpureTextCell {
  processRow(props, row) {
    const { target_investors } = Store.get('founder', {});
    const target = _.find(target_investors, {id: row.id});
    return {
      stage: _.get(target, props.stageKey),
      id: row.id,
      last_response: row.last_response,
      value: _.get(target, props.columnKey),
      canIntro: _.get(row, props.eligibleKey),
      hasEmail: _.get(row, props.emailKey),
    };
  };

  componentWillMount() {
    this.subscription = Store.subscribe('founder', ({target_investors}) => {
      if (!this.state.id) {
        return;
      }
      const target = _.find(target_investors, {id: this.state.id});
      this.setState({
        value: _.get(target, this.props.columnKey),
        stage: _.get(target, this.props.stageKey)
      });
    });
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  renderButton() {
    const { hasEmail, stage, last_response } = this.state;
    const firstStage = stage === _.first(TargetInvestorStagesKeys);
    const introRequest = this.state.value;
    const canIntro = firstStage && this.state.canIntro;

    if (introRequest && last_response) {
      return <IconLine icon="check" line="Responded" className="green" />;
    } else if (introRequest && introRequest.clicks.length) {
      return <IconLine icon="check" line="Clicked" className="green" />;
    } else if (introRequest && introRequest.opened_at) {
      return <IconLine icon="check" line="Opened" className="green" />;
    } else if (introRequest) {
      return <IconLine icon="check" line="Sent" className="green" />;
    } else if (canIntro && hasEmail) {
      return <IconLine icon="mail" line="Request Intro" className="blue" />;
    } else if (canIntro) {
      return <IconLine icon="mail" line="Needs Email" className="blue" />;
    } else {
      return <span className="not-available">-</span>;
    }
  }

  renderValue() {
    return <div className="intro-cell">{this.renderButton()}</div>;
  }
}