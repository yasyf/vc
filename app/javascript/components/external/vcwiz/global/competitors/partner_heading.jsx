import React from 'react';
import ProfileImage from '../shared/profile_image';
import {initials} from '../utils';
import {fullName} from '../../../vcfinder/utils';

export default class PartnerHeading extends React.Component {
  render() {
    const { investor } = this.props;
    const { photo, role, competitor } = investor;
    return (
      <div>
        <ProfileImage fallback={initials(investor)} src={photo || competitor.photo} size={50} className="inline-image" />
        <div className="heading">{fullName(investor)}</div>
        <div className="subheading">
          <span>{role ? `${role}, ${competitor.name}` : competitor.name}</span>
        </div>
      </div>
    );
  }
}