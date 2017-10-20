import React from 'react';
import { RingLoader as Loader } from 'react-spinners';
import ProfileImage from '../shared/profile_image';
import {CompetitorIndustries, InvestorsPath, ReviewAPI} from '../constants.js.erb';
import {fullName, ffetch, ffetchPublic, getDomain, initials} from '../utils';
import {Row, Column} from 'react-foundation';
import ReadMore from '../shared/read_more';
import IconLine from '../shared/icon_line';
import moment from 'moment';
import Company from '../../discover/company';
import Labels from '../shared/labels';
import Truncate from 'react-truncate';
import Tweet from '../shared/tweet';
import Track from '../fields/track';

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
    ffetch(InvestorsPath.id(this.props.id)).then(investor => {
      this.setState({investor});
    });
  }

  onTrackChange = (change) => {
    console.log(change);
  };

  renderLoading() {
    return (
      <div className="text-center loading">
        <Loader color="#2ADBC4" size={200} />
      </div>
    );
  }

  renderHeading() {
    const { photo, role, competitor } = this.state.investor;
    return (
      <div>
        <Row>
          <Column large={3}>
            <ProfileImage fallback={initials(this.state.investor)} src={photo} size={50} className="inline-image" />
            <div className="heading">{fullName(this.state.investor)}</div>
            <div className="subheading">
              <span>{role ? `${role}, ${competitor.name}` : competitor.name}</span>
            </div>
          </Column>
          <Column offsetOnLarge={7} large={1}>
            <Track onChange={this.onTrackChange} />
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

    return (
      <div>
        <h5>Social</h5>
        {this.renderIconLine('book-bookmark', university && university.name)}
        {this.renderIconLine('home', location)}
        {this.renderIconLine('list', '', al_url, 'angel.co')}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter, 'https://twitter.com')}
        {this.renderIconLine('social-linkedin', linkedin, 'https://linkedin.com/in')}
        {this.renderIconLine('web', '', homepage, getDomain(homepage))}
        {this.renderIconLine('clock', average_response_time && moment.duration(average_response_time, 'seconds').humanize())}
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
          <a href={url} target="_blank">{_.truncate(title, {length: 55})}</a>
        </p>
        <p className="post-description">
          {published_at && moment(published_at).fromNow()}
          {context}
        </p>
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
    if (!recent_investments.length) {
      return null;
    } else {
      return <Column large={4}>{this.renderRecentInvestments()}</Column>;
    }
  }

  maybeRenderRecentPostsAndNews() {
    let { recent_news, public_posts } = this.state.investor;
    if (!recent_news.length && !public_posts.length) {
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
    if (!tweets.length) {
      return null;
    }
    return <Tweet tweet={_.sample(tweets)} />;
  }

  onTruncate = isTruncated => {
    if (isTruncated || this.state.fetchedReview) {
      return;
    }
    this.setState({fetchedReview: true});
    ffetchPublic(`${ReviewAPI}?name=${fullName(this.state.investor)}`).then(({errors, review}) => {
      if (errors.length || !review.published || review.overall < 4) {
        return;
      }
      this.setState({review: review.comment});
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
        <div>
          <ReadMore onTruncate={this.onTruncate}>
            {description}
            {this.renderReview()}
          </ReadMore>
        </div>
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