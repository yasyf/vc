import React from 'react';
import ProfileImage from '../shared/profile_image';
import {CompetitorFundTypes, CompetitorIndustries, InvestorsPath, OutreachPath, InvestorPath} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import {ffetch, fullName, isMobile, sendEvent, withDots} from '../utils';
import Actions from '../actions';
import PartnerTab from './partner_tab';
import IconLine from '../shared/icon_line';
import showdown from 'showdown';
import inflection from 'inflection';
import Tabs from '../tabs/tabs';

export default class CompetitorBase extends React.Component {
  constructor(props) {
    super(props);
    this.converter = new showdown.Converter();
    this.state = {
      tab: null,
    };
    this.firstTabChange = true;
  }

  componentDidMount() {
    if (this.props.item.id) {
      sendEvent('competitor_clicked', this.props.item.id);
    }
  }

  onTrackChange = id => update => {
    if (this.props.onTrackChange) {
      this.props.onTrackChange(update);
    } else {
      Actions.trigger('flash', {type: 'success', message: `${this.props.item.name} has been added to your conversation tracker!`, link: OutreachPath});
      ffetch(InvestorsPath.id(id), 'PATCH', {investor: {stage: update.track.value}}).then(() => {
        Actions.trigger('refreshFounder');
      });
    }
  };

  onTabChange = i => {
    this.setState({tab: i});
    if (this.firstTabChange) {
      this.firstTabChange = false;
    } else {
      sendEvent('investor_clicked', this.props.item.partners[i].id);
    }
  };

  renderHeading() {
    const { name, photo, hq, fund_type } = this.props.item;
    const type = _.first(fund_type) && [
      <span key="type">{CompetitorFundTypes[_.first(fund_type)]}</span>,
      <span key="dot">·</span>,
    ];
    return (
      <div>
        <ProfileImage src={photo} size={50} className="inline-image" rounded={false} />
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
    let industries = _.take(industry, isMobile() ? 3 : 7).map(i =>
      <span key={i}>{CompetitorIndustries[i]}</span>
    );
    return <p><b className="info-heading">Top Industries:</b> {withDots(industries)}</p>
  }

  renderInvestments() {
    const { recent_investments } = this.props.item;
    if (!recent_investments || !recent_investments.length) {
      return null;
    }
    let investments = _.take(recent_investments, isMobile() ? 3 : 5).map(c =>
      <span key={c.id}>{this.renderCompany(c)}</span>
    );
    return <p><b className="info-heading">Recent Investments:</b> {withDots(investments)}</p>
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
        {this.renderIconLine('list', '', al_url,  al_url && _.last(al_url.split('/')))}
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
        scrollShadows={true}
        defaultIndex={defaultIndex}
        tabs={partners.map(p => <FakeLink href={InvestorPath.resource(p.id, inflection.dasherize(fullName(p).toLowerCase()))} value={fullName(p)} />)}
        panels={partners.map(p => <PartnerTab onTrackChange={this.onTrackChange(p.id)} investor={p} />)}
        onTabChange={this.onTabChange}
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
}