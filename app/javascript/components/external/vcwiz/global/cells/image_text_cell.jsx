import React from 'react';
import TextCell from './text_cell';
import {Textfit} from 'react-textfit';
import ProfileImage from '../shared/profile_image';

export default class ImageTextCell extends TextCell {
  processRow(props, row) {
    return {
      value: _.get(row, props.columnKey),
      subValue: _.get(row, props.subKey),
      src: _.get(row, props.imageKey),
      fallback: props.fallbackFn ? props.fallbackFn(row) : row[props.fallbackKey],
      verified: _.get(row, props.verifiedKey),
      badge: _.get(row, props.badgeKey),
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
        size={this.props.size}
        verified={this.state.verified}
        badge={this.state.badge}
        transparency={this.props.rowIndex % 2 ? 'F6F7F8' : 'FFFFFF'}
        className="floating-image"
      />
    );
  }

  renderTextfit() {
    if (this.state.subValue) {
      return (
        [
          <Textfit key="value" mode="multi" min={this.props.min} max={this.props.max}>
            <div className="textfit-cell">
              {this.state.value}
            </div>
          </Textfit>,
          <Textfit key="subValue" mode="multi" min={this.props.min} max={this.props.max}>
            <div className="textfit-cell subheading">
              {this.state.subValue}
            </div>
          </Textfit>
        ]
      );
    } else {
      return (
        <Textfit key="value" mode="multi" min={this.props.min} max={this.props.max}>
          <div className="textfit-cell" style={{height: (this.props.size * 2) - 15}}>
            {this.state.value}
          </div>
        </Textfit>
      );
    }
  }

  renderValue() {
    return (
      <div className="image-text-cell">
        {this.renderImage()}
        <div className="image-text" style={{
          marginLeft: `calc(${this.props.size}px + 0.5rem)`,
          width: `calc(95% - ${this.props.size}px - 1rem)`,
        }}>
          {this.renderTextfit()}
        </div>
      </div>
    )
  }
}