import React from 'react';
import ProfileImage from '../shared/profile_image';
import {
  CompetitorFundTypes, CompetitorIndustries, InvestorsPath, OutreachPath,
  InvestorPath, CompanyPath, IntroPathTypes, CompetitorsListsPath,
  MediumScreenSize, FirmPath
} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import {
  ffetch, fullName, isLoggedIn, isMobile, nullOrUndef, sendEvent,
  withDots,
} from '../utils';
import Actions from '../actions';
import Store from '../store';
import PartnerTab from './partner_tab';
import IconLine from '../shared/icon_line';
import showdown from 'showdown';
import inflection from 'inflection';
import Tabs from '../tabs/tabs';
import FakeLink from '../shared/fake_link';
import fetchCompetitorPath from '../fetch_competitor_path';
import IntroPathCount from './intro_path_count';
import PartnerHeading from './partner_heading';
import createHistory from 'history/createBrowserHistory'
import {canUseDOM} from 'exenv';

export default class CompetitorBase extends React.Component {
  constructor(props) {
    super(props);
    this.converter = new showdown.Converter();
    this.state = {
      tab: null,
      path: null,
      dimensions: Store.get('dimensions', {
        width: 0,
        height: 0,
      }),
    };
    this.firstTabChange = true;

    if (canUseDOM) {
      this.history = createHistory();
    }
  }

  componentWillMount() {
    this.mounted = true;
    this.subscription = Store.subscribe('dimensions', dimensions => this.setState({dimensions}));
  }

  componentWillUnmount() {
    this.mounted = false;
    Store.unsubscribe(this.subscription);
    if (this.props.item.id) {
      if (this.history) {
        this.history.go(0);
      }
    }
  }

  componentDidMount() {
    if (this.props.item.id) {
      if (this.history) {
        this.history.push(FirmPath.resource(this.props.item.id, inflection.dasherize(this.props.item.name.toLowerCase())));
      }

      if (!isLoggedIn()) {
        return;
      }

      sendEvent('competitor_clicked', this.props.item.id);
      fetchCompetitorPath(this.props.item.id, path => {
        if (this.mounted && !_.isEmpty(path)) {
          this.setState({path});
        }
      });
    }
  }

  onTrackChange = id => update => {
    if (this.props.onTrackChange) {
      this.props.onTrackChange(update);
    } else {
      const { target_investors } = Store.get('founder', {});
      const target = _.find(target_investors, {competitor_id: this.props.item.id});
      if (!target) {
        Actions.trigger('flash', {type: 'success', message: `${this.props.item.name} has been added to your conversation tracker!`, link: OutreachPath});
      }
      ffetch(InvestorsPath.id(id), 'PATCH', {investor: {stage: update.track.value}}).then(() => {
        Actions.trigger('refreshFounder');
      });
    }
  };

  onTabChange = i => {
    this.setState({tab: i});
    if (this.history) {
      this.history.push(InvestorPath.resource(partner.id, inflection.dasherize(fullName(partner).toLowerCase())));
    }
    if (this.firstTabChange) {
      this.firstTabChange = false;
    } else {
      const partner = this.props.item.partners[i];
      sendEvent('investor_clicked', partner.id);
    }
  };

  renderHeading() {
    const { name, photo, hq, fund_type } = this.props.item;
    const type = _.first(fund_type) && [
      <span key="type">{CompetitorFundTypes[_.first(fund_type)]}</span>,
      <span key="dot">·</span>,
    ];
    return (
      <div className="competitor-heading">
        <ProfileImage src={photo} size={50} className="inline-image" rounded={false} />
        <div className="heading">{name}</div>
        <div className="subheading">
          {type || null}
          <span>{hq}</span>
        </div>
      </div>
    );
  }

  renderCompany({ id, name }) {
    return <a href={CompanyPath.resource(id, inflection.dasherize(name.toLowerCase()))}>{name}</a>;
  }

  renderCompetitor({ id, name }) {
    return <a href={FirmPath.resource(id, inflection.dasherize(name.toLowerCase()))}>{name}</a>;
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

  renderCoinvestors() {
    const { coinvestors } = this.props.item;
    if (!coinvestors || !coinvestors.length) {
      return null;
    }
    let competitors = _.take(coinvestors, isMobile() ? 3 : 5).map(c =>
      <span key={c.id}>{this.renderCompetitor(c)}</span>
    );
    return <p><b className="info-heading">Co-Investors:</b> {withDots(competitors)}</p>
  }

  renderPath() {
    const { path } = this.state;
    if (!_.get(path, 'count')) {
      return null;
    }
    return <IntroPathCount {...path} path={IntroPathTypes.COMPETITOR} id={this.props.item.id} />;
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
        {this.renderCoinvestors()}
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
    const { dimensions, tab: currentTab } = this.state;
    const { partners, matches } = item;

    if (!partners || !partners.length) {
      return null;
    }

    let defaultIndex = tab || _.findIndex(partners, {id: _.first(matches)});
    if (defaultIndex === -1) {
      defaultIndex = undefined;
    }

    const index = nullOrUndef(currentTab) ? (defaultIndex || 0) : currentTab;

    if (partners.length > 1 && dimensions.width > MediumScreenSize) {
      return (
        <Row className="sidebar-wrapper">
          <Column large={2} className="sidebar-list">
            {partners.map((p, i) =>
              <div key={i} onClick={() => this.onTabChange(i)}>
                <PartnerHeading investor={p} short={true} transparency="F5F6F7" className={i === index ? 'active' : undefined} size={45} />
              </div>
            )}
          </Column>
          <Column large={10}><PartnerTab key={index} onTrackChange={this.onTrackChange(partners[index].id)} investor={partners[index]} /></Column>
        </Row>
      );
    } else {
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
  }

  renderTop() {
    return (
      <Row>
        <Column large={9}>
          {this.renderHeading()}
          {this.renderPath()}
          {this.renderCompetitorInfo()}
        </Column>
        <Column large={3}>
          {this.renderCompetitorSocial()}
        </Column>
      </Row>
    );
  }
}