import React from 'react';
import classNames from 'classnames';

export default class ProfileImage extends React.Component {
  static defaultProps = {
    size: 60,
    background: '000000',
    foreground: 'FFFFFF',
    verified: false,
    rounded: true,
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
    return <div className="fallback" style={style}>{fallback || ''}</div>;
  }

  renderImage() {
    let { src, size, foreground, verified, rounded } = this.props;
    const check = verified ? 'l_check,w_0.5,fl_relative,g_south_east/' : '';
    const round = rounded ? 'r_max,' : '';
    const url = `https://res.cloudinary.com/vcwiz/image/fetch/w_${size},h_${size},g_face,c_fill,${round}f_auto,q_auto,b_rgb:${foreground}/${check}${src}`;
    return <img width={size} height={size} src={url} style={this.sizeStyle()} />;
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