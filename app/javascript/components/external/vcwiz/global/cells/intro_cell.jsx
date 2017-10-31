import React from 'react';
import TextCell from './text_cell';
import IconLine from '../shared/icon_line';

export default class IntroCell extends TextCell {
  processIntroRequest(props, row) {
    let introRequest = _.get(row, props.columnKey);
    let canIntro = _.get(row, props.eligibleKey);

    if (!introRequest && canIntro) {
      return <IconLine icon="mail" line="Request Intro" className="blue" />;
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

  processRow(props, row) {
    let value = <div className="intro-cell">{this.processIntroRequest(props, row)}</div>;
    return {value};
  }
}