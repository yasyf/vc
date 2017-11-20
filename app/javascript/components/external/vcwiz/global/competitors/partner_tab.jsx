import React from 'react';
import {CompetitorIndustries, InvestorsPath, ReviewAPI} from '../constants.js.erb';
import {ffetchCached, getDomain} from '../utils';
import {Row, Column} from 'react-foundation';
import ReadMore from '../shared/read_more';
import IconLine from '../shared/icon_line';
import moment from 'moment';
import Company from '../../discover/company';
import Labels from '../shared/labels';
import Truncate from 'react-truncate';
import Tweet from '../shared/tweet';
import Loader from '../shared/loader';
import Track from '../fields/track';
import PartnerHeading from './partner_heading';
import update from 'immutability-helper';

export default class PartnerTab extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      investor: null,
      fetchedReview: false,
      review: null,
    };
  }

  componentDidMount() {
    if (this.props.investor.id) {
      ffetchCached(InvestorsPath.id(this.props.investor.id)).then(investor => {
        this.setState({investor});
      });
    } else {
      this.setState({investor: this.props.investor});
    }
  }

  onTrackChange = change => {
    const target_investor = { ...(this.state.investor.target_investor || {}), stage: change.track.value };
    const investor = update(this.state.investor, {target_investor: {$set: target_investor}});
    this.setState({investor});
    this.props.onTrackChange(change);
  };

  renderLoading() {
    return (
      <div className="text-center loading">
        <Loader />
      </div>
    );
  }

  renderTrack() {
    let stage = this.state.investor.target_investor && this.state.investor.target_investor.stage;
    return <Track onChange={this.onTrackChange} value={stage} />;
  }

  renderHeading() {
    return (
      <div>
        <Row>
          <Column large={8}>
            <PartnerHeading investor={this.state.investor} />
          </Column>
          <Column offsetOnLarge={2} large={2}>
            {this.renderTrack()}
          </Column>
        </Row>
      </div>
    );
  }

  renderIconLine(icon, line, link = null, text = null) {
    return <IconLine icon={icon} line={line} link={link} text={text}/>;
  }

  renderSocial() {
    let {
      location,
      facebook,
      twitter,
      linkedin,
      university,
      homepage,
      average_response_time,
      competitor,
      al_url
    } = this.state.investor;

    if (facebook === competitor.facebook) {
      facebook = null;
    }
    if (twitter === competitor.twitter) {
      twitter = null;
    }

    if (!_.compact([
      location,
      facebook,
      twitter,
      linkedin,
      university,
      homepage,
      average_response_time,
      al_url,
    ]).length) {
      return null;
    }

    return (
      <div>
        <h5>Social</h5>
        {this.renderIconLine('book-bookmark', university && university.name)}
        {this.renderIconLine('home', location)}
        {this.renderIconLine('list', '', al_url, 'angel.co')}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter && `@${twitter}`, 'https://twitter.com')}
        {this.renderIconLine('social-linkedin', linkedin, 'https://linkedin.com/in')}
        {this.renderIconLine('web', '', homepage, getDomain(homepage))}
        {this.renderIconLine('clock', average_response_time && `Average Response Time of ${moment.duration(average_response_time, 'seconds').humanize()}`)}
      </div>
    );
  }

  renderRecentInvestments() {
    let { recent_investments } = this.state.investor;
    return (
      <div>
        <h5>Recent Investments</h5>
        {recent_investments.map(ri => <Company key={ri.id} {...ri} lines={2} fallback={null} />)}
      </div>
    );
  }

  renderPostOrNews = ({ id, url, title, published_at, categories, description }) => {
    let context;
    if (description) {
      context = <Truncate lines={2}>{description}</Truncate>;
    } else {
      context = <Labels items={_.map(categories, 'name')} extraClass="small" plain={true} />;
    }
    return (
      <div key={id}>
        <p className="post-name">
          <a href={url} target="_blank">{_.truncate(title, {length: 50})}</a>
        </p>
        <div className="post-description">
          <p>{published_at && moment(published_at).fromNow()}</p>
          <p>{context}</p>
        </div>
      </div>
    );
  };

  renderRecentPostsAndNews() {
    let { recent_news, public_posts } = this.state.investor;
    let sorted =_.take(_.orderBy(_.concat(recent_news, public_posts), p => p.published_at || '', ['desc']), 3);

    return (
      <div>
        <h5>Blog Posts & News</h5>
        {sorted.map(this.renderPostOrNews)}
      </div>
    );
  }

  maybeRenderRecentInvestments() {
    let { recent_investments } = this.state.investor;
    if (!recent_investments || !recent_investments.length) {
      return null;
    } else {
      return <Column large={4}>{this.renderRecentInvestments()}</Column>;
    }
  }

  maybeRenderRecentPostsAndNews() {
    let { recent_news, public_posts } = this.state.investor;
    if ((!recent_news || !recent_news.length) && (!public_posts || !public_posts.length)) {
      return null;
    } else {
      return <Column large={5}>{this.renderRecentPostsAndNews()}</Column>;
    }
  }

  renderDetails() {
    return (
      <Row>
        <Column large={3}>{this.renderSocial()}</Column>
        {this.maybeRenderRecentInvestments()}
        {this.maybeRenderRecentPostsAndNews()}
      </Row>
    );
  }

  renderTweet() {
    let { tweets } = this.state.investor;
    if (!tweets || !tweets.length) {
      return null;
    }
    return <Row isColumn><Tweet tweet={_.sample(tweets)} /></Row>;
  }

  onTruncate = isTruncated => {
    if (isTruncated || this.state.fetchedReview) {
      return;
    }
    this.setState({fetchedReview: true});
    ffetchCached(InvestorsPath.resource(this.props.investor.id, 'review')).then(({review}) => {
      this.setState({review});
    })
  };

  renderReview() {
    const { review } = this.state;
    if (!review) {
      return null;
    }
    return (
      <div>
        <br />
        <em>{review}</em>
        <span className="dot">-</span>
        <a href="https://knowyourvc.com/" target="_blank">Founder @ KnowYourVC</a>
      </div>
    )
  }

  renderBody() {
    const { investor, review } = this.state;
    if (!investor) {
      return this.renderLoading();
    }

    const { description } = investor;
    return (
      <div>
        {this.renderHeading()}
        {this.renderTweet()}
        <Row isColumn>
          <ReadMore onTruncate={this.onTruncate} lines={3}>
            {description}
            {this.renderReview()}
          </ReadMore>
        </Row>
        <hr />
        {this.renderDetails()}
      </div>
    );
  }

  render() {
    return (
      <div className="partner-tab">
        {this.renderBody()}
      </div>
    );
  }
}