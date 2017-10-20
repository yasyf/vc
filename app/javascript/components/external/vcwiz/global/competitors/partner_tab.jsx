import React from 'react';
import { RingLoader as Loader } from 'react-spinners';
import ProfileImage from '../shared/profile_image';
import {CompetitorIndustries, InvestorsPath} from '../constants.js.erb';
import {fullName, ffetch, getDomain, initials} from '../utils';
import {Row, Column} from 'react-foundation';
import ReadMore from '../shared/read_more';
import IconLine from '../shared/icon_line';
import moment from 'moment';
import Company from '../../discover/company';
import Labels from '../shared/labels';
import Truncate from 'react-truncate';

export default class PartnerTab extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      investor: null,
    };
  }

  componentDidMount() {
    ffetch(InvestorsPath.id(this.props.id)).then(investor => {
      this.setState({investor});
    });
  }

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
        <ProfileImage fallback={initials(this.state.investor)} src={photo} size={50} className="inline-image" />
        <div className="heading">{fullName(this.state.investor)}</div>
        <div className="subheading">
          <span>{role ? `${role}, ${competitor.name}` : competitor.name}</span>
        </div>
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

  renderDetails() {
    return (
      <Row>
        <Column large={3}>{this.renderSocial()}</Column>
        <Column large={4}>{this.renderRecentInvestments()}</Column>
        <Column large={5}>{this.renderRecentPostsAndNews()}</Column>
      </Row>
    );
  }

  renderBody() {
    const { investor } = this.state;
    if (!investor) {
      return this.renderLoading();
    }

    const { description } = investor;
    return (
      <div>
        {this.renderHeading()}
        <p><ReadMore>{description}</ReadMore></p>
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