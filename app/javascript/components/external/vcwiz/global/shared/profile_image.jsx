import React from 'react';
import classNames from 'classnames';

export default class ProfileImage extends React.Component {
  static defaultProps = {
    size: 60,
    background: '000000',
    foreground: 'FFFFFF',
    transparency: 'FFFFFF',
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
    let { src, size, transparency, verified, rounded, badge } = this.props;
    const filters = _.compact([
      `w_${size},h_${size},g_face,c_fill,${rounded ? 'r_max,' : ''}f_auto,q_auto,b_rgb:${transparency}`,
      verified ? 'l_check,w_0.5,fl_relative,g_south_east' : null,
      badge ? 'l_badge,e_multiply,w_0.59,fl_relative,g_south_east' : null,
      badge ? `w_0.8,l_text:Helvetica_22_bold_center_stroke:${badge},co_white,bo_2px_solid_rgb:2A2A2A,g_xy_center,x_0.7,y_0.7` : null,
    ]);
    const url = `https://res.cloudinary.com/vcwiz/image/fetch/${filters.join('/')}/${src}`;
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