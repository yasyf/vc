import React from 'react';
import TextCell from './text_cell';
import PlaceholderInput from '../fields/placeholder_input';

export default class PlaceholderCell extends TextCell {
  onInputChange = value => {
    this.onChange({[this.props.columnKey]: {value: value}});
  };

  renderValue() {
    return (
      <div className="placeholder-cell">
        <PlaceholderInput
          value={this.state.value}
          placeholder="Click to add note..."
          onChange={this.onInputChange}
        />
      </div>
    );
  }
}