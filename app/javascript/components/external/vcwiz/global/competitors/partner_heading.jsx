import React from 'react';
import ProfileImage from '../shared/profile_image';
import {fullName, initials} from '../utils';
import classNames from 'classnames';

export default class PartnerHeading extends React.Component {
  static defaultProps = {
    short: false,
    size: 50,
  };

  render() {
    const { investor, transparency, short, className, size } = this.props;
    const { photo, verified, first_name } = investor;
    const role = investor.role || 'VC';
    const competitor = investor.competitor || {};
    return (
      <div className={classNames('partner-heading-inner', className)}>
        <ProfileImage transparency={transparency} verified={verified} fallback={initials(investor)} src={photo || competitor.photo} size={size} className="inline-image" />
        <div className="heading">{short ? first_name : fullName(investor)}</div>
        <div className="subheading">
          <span>{short ? _.truncate(role, {length: 15}) : `${role}, ${competitor.name}`}</span>
        </div>
      </div>
    );
  }
}