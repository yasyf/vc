import React from 'react';
import TextCell from './text_cell';

export default class NullStateCell extends TextCell {
  updateValue() {
    this.setState({loading: false});
  }

  renderValue() {
    return (
      <div className="null-state-cell">
        <h5>No results found! Try broadening your search options.</h5>
      </div>
    );
  }
}