import React from 'react';
import TextCell from './text_cell';
import Truncate from 'react-truncate';

export default class TruncatedTextCell extends TextCell {
  static defaultProps = {
    lines: 2,
  };

  renderValue() {
    return (
      <div className="plain-text-cell">
        <Truncate lines={this.props.lines}>{this.state.value}</Truncate>
      </div>
    );
  }
}