import React from 'react';
import TextCell from './text_cell';
import PlaceholderInput from '../fields/placeholder_input';

export default class PlaceholderCell extends TextCell {
  onInputChange = update => {
    this.onChange({[this.props.columnKey]: {value: update[this.props.columnKey]}});
  };

  renderValue() {
    return (
      <div className="placeholder-cell">
        <PlaceholderInput
          name={this.props.columnKey}
          value={this.state.value}
          placeholder="Click to add note..."
          multiline={true}
          onChange={this.onInputChange}
        />
      </div>
    );
  }
}