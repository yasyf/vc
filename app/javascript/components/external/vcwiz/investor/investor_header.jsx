import React from 'react';
import ProfileImage from '../global/shared/profile_image';
import {initials} from '../global/utils';
import CompanyImage from '../discover/company_image';

export default class InvestorHeader extends React.Component {
  static defaultProps = {
    imageSize: 100,
  };

  renderProfileImage(person) {
    const { imageSize } = this.props;
    return <ProfileImage fallback={initials(person)} src={person.photo} size={imageSize} className="inline-image" />;
  }

  renderCompanyImage(company) {
    const { imageSize } = this.props;
    return (
      <div className="rounded-image inline-image" style={{width: `${imageSize}px`, height: `${imageSize}px`}}>
        <CompanyImage domain={company.domain} size={imageSize} />
      </div>
    );
  }

  render() {
    const { investor, founder, company } = this.props;
    return (
      <div>
        <div className="intro-header">
          <div className="images investor-images">
            {this.renderProfileImage(investor.competitor)}
            {this.renderProfileImage(investor)}
          </div>
          <div className="arrows">&harr;</div>
          <div className="images founder-images">
            {this.renderProfileImage(founder)}
            {this.renderCompanyImage(company)}
          </div>
        </div>
        <h3>Hey, {investor.first_name}!</h3>
      </div>
    );
  }
}