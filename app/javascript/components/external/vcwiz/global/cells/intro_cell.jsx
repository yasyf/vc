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
      value: _.get(row, props.columnKey),
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
      this.setState({stage: _.get(target, this.props.stageKey)});
    });
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  renderButton(props, row) {
    const { hasEmail, stage } = this.state;
    const firstStage = stage === _.first(TargetInvestorStagesKeys);
    const introRequest = this.state.value;
    const canIntro = firstStage && this.state.canIntro;

    if (canIntro && hasEmail) {
      return <IconLine icon="mail" line="Request Intro" className="blue" />;
    } else if (canIntro) {
      return <IconLine icon="mail" line="Needs Email" className="blue" />;
    } else if (!introRequest && !canIntro) {
      return <span className="not-available">-</span>;
    } else if (row.last_response) {
      return <IconLine icon="check" line="Responded" className="green" />;
    } else if (introRequest.clicks.length) {
      return <IconLine icon="check" line="Clicked" className="green" />;
    } else if (introRequest.opened_at) {
      return <IconLine icon="check" line="Opened" className="green" />;
    } else {
      return <IconLine icon="check" line="Sent" className="green" />;
    }
  }

  renderValue() {
    return <div className="intro-cell">{this.renderButton()}</div>;
  }
}