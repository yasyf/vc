import React from 'react';
import Labels from '../global/shared/labels';
import {CompetitorIndustries} from '../global/constants.js.erb';
import moment from 'moment';
import CompanyImage from './company_image';

export default class CompanyCard extends React.Component {
  render() {
    const { domain, website, name, industry, funded_at, description } = this.props.company;

    return (
      <div className="company-card">
        <div className="company-meta">
          <div className="company-name">
            <h3>Investors of {this.props.website ? <a href={website} target="_blank">{name}</a> : name}</h3>
          </div>
          <div className="company-info">
            <div className="company-labels">
              <Labels items={industry} translate={CompetitorIndustries} />
            </div>
            <div className="company-description">
              <p>
                {funded_at && `Last funded ${moment(funded_at).fromNow()}.`}
              </p>
              <p className="company-description-text">
                {description}
              </p>
            </div>
          </div>
        </div>
        <div className="company-image">
          <CompanyImage domain={domain} size={100} />
        </div>
      </div>
    );
  }
}