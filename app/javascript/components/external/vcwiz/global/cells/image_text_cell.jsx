import React from 'react';
import TextCell from './text_cell';
import {Textfit} from 'react-textfit';
import {Row, Column} from 'react-foundation';

export default class ImageTextCell extends TextCell {
  processRow(props, row) {
    return {
      value: row[props.columnKey],
      src: row[props.imageKey],
      fallback: row[props.fallbackKey],
    };
  };

  placeholderProps() {
    return {
      ...super.placeholderProps(),
      type: 'media',
      rows: 2,
    };
  }

  renderImage() {
    let src = this.state.src ? this.state.src : `https://via.placeholder.com/40x40/000000/FFFFFF?text=${this.state.fallback}`;
    return <div className="rounded-image floating-image"><img src={src} /></div>;
  }

  renderValue() {
    return (
      <div>
        {this.renderImage()}
        <div className="image-text">
          <Textfit mode="single" min={12} max={20}>
            <div className="textfit-cell">
              {this.state.value}</div>
          </Textfit>
        </div>
      </div>
    )
  }
}