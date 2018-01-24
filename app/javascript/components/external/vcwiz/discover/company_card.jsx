import React from 'react';
import Labels from '../global/shared/labels';
import {CompetitorIndustries} from '../global/constants.js.erb';
import moment from 'moment';
import CompanyImage from './company_image';
import IconLine from '../global/shared/icon_line';

export default class CompanyCard extends React.Component {
  renderIconLine(icon, line, link = null, text = null) {
    return <IconLine icon={icon} line={line} link={link} text={text}/>;
  }

  renderCompanySocial() {
    let { name, location, al_url, cb_url, crunchbase_id, facebook, twitter, domain } = this.props.company;
    return (
      <div className="company-social">
        {this.renderIconLine('home', location)}
        {this.renderIconLine('icn-al', '', al_url, `${name} on AngelList`)}
        {this.renderIconLine('icn-cb', '', cb_url, `${name} on Crunchbase`)}
        {this.renderIconLine('web', domain, 'http://')}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter && `@${twitter}`, 'https://twitter.com')}
      </div>
    );
  }

  render() {
    const { domain, website, name, industry, funded_at, description } = this.props.company;
    return (
      <div className="company-card">
        <div className="company-meta">
          <div className="company-name">
            <h3>{name}</h3>
          </div>
          <div className="company-info">
            <div className="company-description">
              <p>
                {funded_at && `Last funded ${moment(funded_at).fromNow()}.`}
              </p>
              <p className="company-description-text">
                {description}
              </p>
            </div>
            <div className="company-labels">
              <Labels items={industry} translate={CompetitorIndustries} />
            </div>
          </div>
        </div>
        {this.renderCompanySocial()}
        <div className="company-image">
          <CompanyImage domain={domain} size={100} />
        </div>
      </div>
    );
  }
}