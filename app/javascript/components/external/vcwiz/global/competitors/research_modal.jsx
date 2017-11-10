import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import ProfileImage from '../shared/profile_image';
import {CompetitorFundTypes, CompetitorIndustries, InvestorsPath} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import {ffetch, flush, fullName, sendEvent, withDots} from '../utils';
import PartnerTab from './partner_tab';
import IconLine from '../shared/icon_line';
import showdown from 'showdown';
import Tabs from '../tabs/tabs';

export default class ResearchModal extends React.Component {
  constructor(props) {
    super(props);
    this.converter = new showdown.Converter();
    this.state = {
      tab: null,
    };
  }

  componentDidMount() {
    if (this.props.item.id) {
      sendEvent('competitor_clicked', this.props.item.id);
    }
  }

  onTrackChange = id => update => {
    flush();
    if (this.props.onTrackChange) {
      this.props.onTrackChange(update);
    } else {
      ffetch(InvestorsPath.id(id), 'PATCH', {investor: {stage: update.track.value}});
    }
  };

  onTabChange = i => {
    this.setState({tab: i});
  };

  renderHeading() {
    const { name, photo, hq, fund_type } = this.props.item;
    const type = _.first(fund_type) && [
      <span key="type">{CompetitorFundTypes[_.first(fund_type)]}</span>,
      <span key="dot">·</span>,
    ];
    return (
      <div>
        <ProfileImage src={photo} size={50} className="inline-image" />
        <div className="heading">{name}</div>
        <div className="subheading">
          {type || null}
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
        <div
          className="description scroll-shadow"
          dangerouslySetInnerHTML={{ __html: this.converter.makeHtml(description) }}
        />
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
  }

  renderBottom() {
    const { tab, item } = this.props;
    const { partners, matches } = item;

    if (!partners || !partners.length) {
      return null;
    }

    let defaultIndex = tab || _.findIndex(partners, {id: _.first(matches)});
    if (defaultIndex === -1) {
      defaultIndex = undefined;
    }

    return (
      <Tabs
        onTabChange={this.onTabChange}
        defaultIndex={defaultIndex}
        tabs={partners.map(fullName)}
        panels={partners.map(p => <PartnerTab onTrackChange={this.onTrackChange(p.id)} investor={p} />)}
      />
    );
  }

  renderTop() {
    return (
      <Row>
        <Column large={8}>
          {this.renderHeading()}
          {this.renderCompetitorInfo()}
        </Column>
        <Column large={3} offsetOnLarge={1}>
          {this.renderCompetitorSocial()}
        </Column>
      </Row>
    );
  }

  render() {
    const { item } = this.props;
    const { tab } = this.state;
    return (
      <OverlayModal
        name="research"
        idParams={{item, tab}}
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}