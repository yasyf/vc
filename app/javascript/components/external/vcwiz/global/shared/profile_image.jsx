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
    const check = verified ? 'l_check,w_0.5,fl_relative,g_south_east/' : '';
    const round = rounded ? 'r_max,' : '';
    const filters = _.compact([
      `w_${size},h_${size},g_face,c_fill,${round}f_auto,q_auto,b_rgb:${transparency}`,
      badge ? 'l_badge,e_multiply,w_0.5,fl_relative,g_south_east' : null,
      badge ? `l_text:Helvetica_18_bold_stroke:${badge},co_white,bo_1px_solid_darkgray,g_south_east,x_0.17,y_0.1` : null,
    ]);
    const url = `https://res.cloudinary.com/vcwiz/image/fetch/${filters.join('/')}/${check}${src}`;
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