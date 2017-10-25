import React from 'react';
import {UnpureTextCell} from './text_cell';
import Track from '../fields/track';

export default class TrackCell extends UnpureTextCell {
  renderValue() {
    return (
      <div className='track-cell'>
        <Track
          name={this.props.columnKey}
          value={this.state.value}
          onChange={this.onChange}
        />
      </div>
    )
  }
}