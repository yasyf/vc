import React from 'react';
import ProfileImage from '../global/shared/profile_image';
import {fullName, initials} from '../global/utils';

export default class Partner extends React.Component {
  static defaultProps = {
    showRole: true,
  };

  render() {
    const { investor, competitor, showRole, onClick } = this.props;
    const { photo, id, role } = investor;
    return (
      <div className="partner" onClick={onClick}>
        <i className="line-icon fi-x" onClick={this.props.onRemove(id)} />
        <ProfileImage transparency="E9E9E9" fallback={initials(investor)} src={photo || competitor.photo} size={50} className="inline-image" />
        <span>{fullName(investor)} {(role && showRole) ? `(${role})` : ''}</span>
      </div>
    );
  }
}
