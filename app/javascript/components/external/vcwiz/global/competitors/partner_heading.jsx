import React from 'react';
import ProfileImage from '../shared/profile_image';
import {fullName, initials} from '../utils';

export default class PartnerHeading extends React.Component {
  render() {
    const { investor, transparency } = this.props;
    const { photo, role, competitor, verified } = investor;
    return (
      <div>
        <ProfileImage transparency={transparency} verified={verified} fallback={initials(investor)} src={photo || competitor.photo} size={50} className="inline-image" />
        <div className="heading">{fullName(investor)}</div>
        <div className="subheading">
          <span>{role ? `${role}, ${competitor.name}` : competitor.name}</span>
        </div>
      </div>
    );
  }
}