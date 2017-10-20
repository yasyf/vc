import React from 'react';
import {UnpureTextCell} from './text_cell';
import Track from '../fields/track';

export default class TrackCell extends UnpureTextCell {
  onChange = change => {
    console.log(change);
    this.setState({value: change.track.value});
  };

  renderValue() {
    return (
      <div className='track-cell'>
        <Track value={this.state.value} onChange={this.onChange} />
      </div>
    )
  }
}