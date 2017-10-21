import React from 'react';
import classNames from 'classnames';

export default class ProfileImage extends React.Component {
  static defaultProps = {
    size: 60,
    background: '000000',
    foreground: 'FFFFFF',
  };

  sizeStyle() {
    let { size } = this.props;
    return {width: `${size}px`, height: `${size}px`};
  };

  renderFallback() {
    let { fallback, size, background, foreground } = this.props;
    let style = {
      lineHeight: `${size}px`,
      color: `#${foreground}`,
      backgroundColor: `#${background}`,
      ...this.sizeStyle()
    };
    return <div className="fallback" style={style}>{fallback}</div>;
  }

  renderImage() {
    let { src, size } = this.props;
    return <img width={size} height={size} src={src} style={this.sizeStyle()} />
  }

  render() {
    let { className, src } = this.props;
    return (
      <div className={classNames('rounded-image', className)} style={this.sizeStyle()}>
        {src ? this.renderImage() : this.renderFallback()}
      </div>
    );
  }
}