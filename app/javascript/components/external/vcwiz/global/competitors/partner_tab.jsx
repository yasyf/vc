import React from 'react';
import {CompetitorIndustries, InvestorsPath, ReviewAPI, IntroPathTypes} from '../constants.js.erb';
import Store from '../store';
import {
  ffetchCached, getDomain, humanizeList,
  humanizeTravelStatus,
} from '../utils';
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
import IntroPathCount from './intro_path_count';

export default class PartnerTab extends React.Component {
  static defaultProps = {
    fetch: true,
    initiallyExpanded: false,
  };

  constructor(props) {
    super(props);

    const { target_investors } = Store.get('founder', {});

    this.state = {
      investor: props.fetch ? null : props.investor,
      target: _.find(target_investors, {investor_id: props.investor.id}),
      fetchedReview: !!props.review,
      review: props.review || null,
      interactions: props.interactions || null,
    };
  }

  componentWillMount() {
    this.subscription = Store.subscribe('founder', ({target_investors}) => {
      const target = _.find(target_investors, {investor_id: this.props.investor.id});
      if (!_.isEqual(target, this.state.target))
        this.setState({target});
    });
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  componentDidMount() {
    if (this.props.investor.id) {
      if (this.props.fetch) {
        ffetchCached(InvestorsPath.id(this.props.investor.id)).then(investor => {
          this.setState({investor});
        });
      }
      if (!this.state.interactions) {
        ffetchCached(InvestorsPath.resource(this.props.investor.id, 'interactions'), true).then(({interactions}) => {
          this.setState({interactions});
        });
      }
    } else {
      this.setState({investor: this.props.investor});
    }
  }

  onTrackChange = change => {
    const target = (
      this.state.target
        ? update(this.state.target, {stage: {$set: change.track.value}})
        : {stage: change.track.value}
    );
    this.setState({target});
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
    const stage = this.state.target && this.state.target.stage;
    return <Track onChange={this.onTrackChange} value={stage} />;
  }

  renderHeading() {
    return (
      <div className="partner-heading">
        <Row>
          <Column large={8}>
            <PartnerHeading investor={this.state.investor} />
          </Column>
          <Column offsetOnLarge={1} large={3}>
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
        {this.renderIconLine('list', '', al_url, al_url && _.last(al_url.split('/')))}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter && `@${twitter}`, 'https://twitter.com')}
        {this.renderIconLine('social-linkedin', linkedin, 'https://linkedin.com/in')}
        {this.renderIconLine('web', '', homepage, getDomain(homepage))}
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
        <em>{review.text}</em>
        <span className="dot">-</span>
        <a href={`https://knowyourvc.com/investors/${review.id}`} target="_blank">Founder @ KnowYourVC</a>
      </div>
    )
  }

  renderPath() {
    const { interactions } = this.state;
    const { paths } = interactions;
    if (!_.get(paths, 'count')) {
      return null;
    }
    return <IntroPathCount key="path" {...paths} path={IntroPathTypes.INVESTOR} id={this.props.investor.id} />;
  }

  renderInteractions() {
    const { investor, interactions } = this.state;
    if (_.isEmpty(_.omitBy(interactions, _.isEmpty))) {
      return null;
    }
    const { first_name } = investor;
    const { last_contact, travel_status, opened_at, open_city, overlap, entities, path } = interactions;
    const fragments = _.compact([
      this.renderPath(),
      last_contact && <span key="last_contact">&nbsp;You last heard from {first_name} {moment(last_contact).fromNow()}.</span>,
      opened_at && !last_contact && <span key="last_contact">&nbsp;You emailed {first_name} {moment(opened_at).fromNow()}.</span>,
      travel_status && <span key="travel_status">&nbsp;Last we saw, {first_name} was {humanizeTravelStatus(travel_status, open_city)}.</span>,
      overlap && overlap.length && <span key="overlap">&nbsp;You and {first_name} both love to talk about {humanizeList(overlap.map(o => <b>{o.name}</b>))}!</span>,
      entities.length && (!overlap || !overlap.length) && <span key="entities">&nbsp;{first_name} often talks about {humanizeList(entities.map(o => <b>{o.name}</b>))}.</span>,
    ]);
    if (!fragments.length) {
      return null;
    }
    return <Row isColumn className="interactions">{fragments}</Row>;
  }

  renderBody() {
    const { initiallyExpanded } = this.props;
    const { investor, review } = this.state;
    if (!investor) {
      return this.renderLoading();
    }

    const { description } = investor;
    return (
      <div>
        {this.renderHeading()}
        {this.renderTweet()}
        {this.renderInteractions()}
        <Row isColumn>
          <ReadMore initiallyExpanded={initiallyExpanded} onTruncate={this.onTruncate} lines={3} length={description && description.length}>
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