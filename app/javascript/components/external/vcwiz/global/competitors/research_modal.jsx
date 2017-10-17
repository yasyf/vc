import React from 'react';
import Modal from 'react-modal';
import ProfileImage from '../shared/profile_image';
import {CompetitorFundTypes, CompetitorIndustries} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';

const dots = n => _.times(n, i => <span key={`dot-${i}`} className="dot">·</span>);
const withDots = a => _.flatMap(_.zip(a, dots(a.length - 1)));

export default class ResearchModal extends React.Component {
  renderHeading() {
    const { name, photo, hq, fund_type } = this.props;
    return (
      <div>
        <ProfileImage src={photo} size={50} className="inline-image" />
        <div className="heading">{name}</div>
        <div className="subheading">
          <span>{CompetitorFundTypes[_.first(fund_type)]}</span>
          <span>·</span>
          <span>{hq}</span>
        </div>
      </div>
    );
  }

  renderCompany({ crunchbase_id, domain, name }) {
    let url =
      (domain && `http://${domain}`) ||
      (crunchbase_id && `https://www.crunchbase.com/organization/${crunchbase_id}`);
    return url ? <a href={url} target="_blank">{name}</a> : name;
  }

  renderIndustries() {
    const { industry } = this.props;
    if (!industry) {
      return null;
    }
    let industries = industry.map(i =>
      <span key={i}>{CompetitorIndustries[i]}</span>
    );
    return <p><b>Top Industries</b>: {withDots(industries)}</p>
  }

  renderInvestments() {
    const { recent_investments } = this.props;
    if (!recent_investments) {
      return null;
    }
    let investments = recent_investments.map(c =>
      <span key={c.id}>{this.renderCompany(c)}</span>
    );
    return <p><b>Investments</b>: {withDots(investments)}</p>
  }

  renderCompetitorInfo() {
    const { description } = this.props;

    return (
      <div className="competitor-info">
        <p className="description">{description}</p>
        {this.renderIndustries()}
        {this.renderInvestments()}
      </div>
    );
  }

  renderIconLine(icon, line, link = null, text = null) {
    if (!line && !text) {
      return null;
    }
    let inner = text || line;
    let href = text ? link : `${link}/${line}`;
    let body = link ? <a href={href} target="_blank">{inner}</a> : inner;
    return <p className="icon"><i className={`line-icon fi-${icon}`}/>{body}</p>
  }

  renderCompetitorSocial() {
    let { al_url, cb_url, facebook, twitter, domain } = this.props;
    return (
      <div className="competitor-social">
        {this.renderIconLine('list', '', al_url, 'angel.co')}
        {this.renderIconLine('info', '', cb_url, 'crunchbase')}
        {this.renderIconLine('web', domain, 'http://')}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', `@${twitter}`, 'https://twitter.com')}
      </div>
    )
  };

  renderModal() {
    return (
      <div className="research-modal">
        <Row>
          <Column large={9}>
            {this.renderHeading()}
            {this.renderCompetitorInfo()}
          </Column>
          <Column large={2} offsetOnLarge={1}>
            {this.renderCompetitorSocial()}
          </Column>
        </Row>
      </div>
    )
  }

  render() {
    const { name, onClose } = this.props;
    return (
      <Modal
        isOpen={true}
        onRequestClose={onClose}
        contentLabel={name}
        overlayClassName="modal-overlay"
        className="modal-content"
      >
        {this.renderModal()}
      </Modal>
    )
  }
}