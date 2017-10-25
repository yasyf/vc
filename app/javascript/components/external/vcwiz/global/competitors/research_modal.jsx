import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import ProfileImage from '../shared/profile_image';
import {CompetitorFundTypes, CompetitorIndustries, TargetInvestorsPath} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import {ffetch, fullName, withDots} from '../utils';
import PartnerTab from './partner_tab';
import IconLine from '../shared/icon_line';
import showdown from 'showdown';

export default class ResearchModal extends OverlayModal {
  constructor(props) {
    super(props);
    this.converter = new showdown.Converter();
  }

  onTrackChange = id => update => {
    ffetch(TargetInvestorsPath.id(id), 'POST', {stage: update.track.value});
  };

  renderHeading() {
    const { name, photo, hq, fund_type } = this.props.item;
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
    const { industry } = this.props.item;
    if (!industry || !industry.length) {
      return null;
    }
    let industries = industry.map(i =>
      <span key={i}>{CompetitorIndustries[i]}</span>
    );
    return <p><b>Top Industries</b>: {withDots(industries)}</p>
  }

  renderInvestments() {
    const { recent_investments } = this.props.item;
    if (!recent_investments || !recent_investments.length) {
      return null;
    }
    let investments = recent_investments.map(c =>
      <span key={c.id}>{this.renderCompany(c)}</span>
    );
    return <p><b>Recent Investments</b>: {withDots(investments)}</p>
  }

  renderCompetitorInfo() {
    const { description } = this.props.item;

    return (
      <div className="competitor-info">
        <p className="description" dangerouslySetInnerHTML={{ __html: this.converter.makeHtml(description) }} />
        {this.renderIndustries()}
        {this.renderInvestments()}
      </div>
    );
  }

  renderIconLine(icon, line, link = null, text = null) {
    return <IconLine icon={icon} line={line} link={link} text={text}/>;
  }

  renderCompetitorSocial() {
    let { al_url, cb_url, crunchbase_id, facebook, twitter, domain } = this.props.item;
    return (
      <div className="competitor-social">
        {this.renderIconLine('list', '', al_url, 'angel.co')}
        {this.renderIconLine('info', '', cb_url, crunchbase_id)}
        {this.renderIconLine('web', domain, 'http://')}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter && `@${twitter}`, 'https://twitter.com')}
      </div>
    )
  };

  renderBottom() {
    let { partners, matches } = this.props.item;

    if (!partners || !partners.length) {
      return null;
    }

    let defaultIndex = _.findIndex(partners, {id: _.first(matches)});
    if (defaultIndex === -1) {
      defaultIndex = undefined;
    }

    return (
      <Tabs selectedTabPanelClassName="tab-panel" defaultIndex={defaultIndex}>
        <div className="tab-list-wrapper">
          <TabList className="tab-list">
            {partners.map(p => <Tab key={p.id}>{fullName(p)}</Tab>)}
          </TabList>
        </div>
        {partners.map(p =>
          <TabPanel key={p.id}>
            <PartnerTab onTrackChange={this.onTrackChange(p.id)} investor={p} />
          </TabPanel>
        )}
      </Tabs>
    );
  }

  renderTop() {
    return (
      <Row>
        <Column large={9}>
          {this.renderHeading()}
          {this.renderCompetitorInfo()}
        </Column>
        <Column large={2} offsetOnLarge={1}>
          {this.renderCompetitorSocial()}
        </Column>
      </Row>
    );
  }
}