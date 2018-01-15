import React from 'react';
import ProfileImage from '../shared/profile_image';
import {fullName, initials} from '../utils';
import classNames from 'classnames';

export default class PartnerHeading extends React.Component {
  static defaultProps = {
    short: false,
  };

  render() {
    const { investor, transparency, short, className } = this.props;
    const { photo, verified, first_name } = investor;
    const role = investor.role || 'VC';
    const competitor = investor.competitor || {};
    return (
      <div className={classNames('partner-heading-inner', className)}>
        <ProfileImage transparency={transparency} verified={verified} fallback={initials(investor)} src={photo || competitor.photo} size={50} className="inline-image" />
        <div className="heading">{short ? first_name : fullName(investor)}</div>
        <div className="subheading">
          <span>{short ? _.truncate(role, {length: 13}) : `${role}, ${competitor.name}`}</span>
        </div>
      </div>
    );
  }
}