import React from 'react';
import TextCell from './text_cell';
import {Textfit} from 'react-textfit';
import ProfileImage from '../shared/profile_image';

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
    return (
      <ProfileImage
        src={this.state.src}
        fallback={this.state.fallback}
        className="floating-image"
      />
    );
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