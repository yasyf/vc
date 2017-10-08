import React from 'react';
import TextCell from './text_cell';
import {Textfit} from 'react-textfit';

export default class ImageTextCell extends TextCell {
  processRow(props, row) {
    return {
      value: row[props.columnKey],
      src: row[props.imageKey],
      fallback: row[props.fallbackKey],
    };
  };

  renderImage() {
    let src = this.state.src ? this.state.src : `http://via.placeholder.com/40x40/000000/FFFFFF?text=${this.state.fallback}`;
    return <div className="rounded-image"><img src={src} /></div>;
  }

  renderValue() {
    return (
      <div>
        <Textfit mode="single" min={12} max={20}>
          {this.renderImage()}
          <div className="image-text large">{this.state.value}</div>
        </Textfit>
      </div>
    )
  }
}