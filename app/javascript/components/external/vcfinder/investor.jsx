import * as linkify from 'linkifyjs';
require('linkifyjs/plugins/mention')(linkify);
require('linkifyjs/plugins/hashtag')(linkify);

import React from 'react';
import inflection from 'inflection';
import moment from 'moment';
import {fullName, ffetch, getDomain} from './utils';
import {InvestorsPath} from './constants.js.erb';
import ReadMore from './shared/read_more';
import Slider from 'react-slick';
import Industries from './shared/industries';
import Company from './company';
import Linkify from 'linkifyjs/react';

const sliderSettings = {
  infinite: true,
  slidesToShow: 1,
  slidesToScroll: 1,
  speed: 500,
  autoplay: true,
  autoplaySpeed: 10000,
  arrows: true,
  adaptiveHeight: true
};

const linkifyOptions = {
  formatHref: (href, type) => {
    let val = href.substring(1);
    switch (type) {
    case 'hashtag':
      return `https://twitter.com/hashtag/${val}`;
    case 'mention':
      return `https://twitter.com/${val}`;
    default:
      return href;
    }
  },
  target: '_blank',
};

export default class Investor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      investor: this.props.investor,
      loaded: false,
      posts: [],
      tweets: []
    };
  }

  componentDidMount() {
    ffetch(InvestorsPath.id(this.state.investor.id)).then(investor => {
      this.setState({investor, loaded: true});
    });
    ffetch(InvestorsPath.resource(this.state.investor.id, 'posts')).then(posts => {
      this.setState({posts});
    });
    ffetch(InvestorsPath.resource(this.state.investor.id, 'tweets')).then(tweets => {
      this.setState({tweets});
    });
  }

  renderPhoto() {
    if (this.state.investor.photo) {
      return (
        <div className="float-center text-center">
          <img src={this.state.investor.photo} />
        </div>
      );
    } else {
      return null;
    }
  }

  renderIndustries() {
    return <Industries industry={this.state.investor.industry}/>;
  }

  renderTweets() {
    if (!this.state.tweets.length) {
      return null;
    }

    let tweets = this.state.tweets.map(tweet => {
      return (
        <div className="pad-top-less" key={tweet.id}>
          <i className="line-icon fi-megaphone"/>
          <Linkify options={linkifyOptions}>&ldquo;{tweet.text}&rdquo;</Linkify>
          - <span className="faded">{moment(tweet.created_at).fromNow()}</span>
        </div>
      );
    });

    let settings = {
      ...sliderSettings,
      arrows: false,
      autoplaySpeed: 6500
    };

    return (
      <Slider {...settings}>
        {tweets}
      </Slider>
    );
  }

  renderIconLine(icon, line, link = null) {
    if (!line) {
      return null;
    }
    let body = line;
    if (link) {
      body = <a href={`${link}/${line}`} target="_blank">{line}</a>;
    }
    return <p className="icon"><i className={`line-icon fi-${icon}`}/>{body}</p>;
  }

  renderHomepage() {
    let {homepage} = this.state.investor;
    if (!homepage) {
      return null;
    }
    return (
      <p className="icon">
        <i className="line-icon fi-web"/>
        <a href={homepage} target="_blank">{getDomain(homepage) || 'Website'}</a>
      </p>
    );
  }

  renderPosts() {
    if (!this.state.posts.length) {
      return null;
    }
    let posts = this.state.posts.map(post => {
      let industry = post.categories.map(c =>
        inflection.titleize(c.replace(/-/g, '_'))
      );
      return (
        <div key={post.url}>
          <h6>
            <a href={post.url} target="_blank">{post.title}</a>
            <span className="faded"> - {moment(post.published).fromNow()}</span>
          </h6>
          <div>
            <Industries industry={industry} extraClass="small"/>
          </div>
        </div>
      );
    });
    return (
      <div>
        <div className="row">
          <div className="small-12 columns">
            <h4>Blog Posts</h4>
            {posts}
          </div>
        </div>
        <hr/>
      </div>
    );
  }

  renderRecentInvestments() {
    let recentInvestments = this.state.investor.competitor.recent_investments;
    if (!recentInvestments.length) {
      return null;
    }
    let recents = recentInvestments.map(ri =>
      <div key={ri.name}><Company company={ri}/></div>
    );
    return (
      <div>
        <h4>Investments</h4>
        <Slider {...sliderSettings}>
          {recents}
        </Slider>
      </div>
    );
  }

  renderDetailed() {
    if (!this.state.loaded) {
      return <div className="text-center">Loading...</div>;
    }

    let {
      description,
      location,
      facebook,
      twitter,
      linkedin,
      competitor
    } = this.state.investor;

    return (
      <div>
        <div className="float-center text-center">
          {this.renderIndustries()}
          {this.renderTweets()}
        </div>
        <hr/>
        {this.renderPosts()}
        <div className="row">
          <div className="small-8 columns">
            <p><ReadMore>{description}</ReadMore></p>
          </div>
          <div className="small-4 columns">
            {this.renderIconLine('home', location)}
            {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
            {this.renderIconLine('social-twitter', twitter, 'https://twitter.com')}
            {this.renderIconLine('social-linkedin', linkedin, 'https://linkedin.com/in')}
            {this.renderHomepage()}
          </div>
        </div>
        <hr/>
        <div className="row">
          <div className="small-8 columns">
            <p><ReadMore>{competitor.description}</ReadMore></p>
          </div>
          <div className="small-4 columns">
            {this.renderRecentInvestments()}
          </div>
        </div>
      </div>
    );
  }

  renderProfile() {
    let {role, competitor} = this.state.investor;
    return (
      <div>
        <div className="float-center text-center">
          <h3>{fullName(this.state.investor)}</h3>
          <h4>{role}, {competitor.name}</h4>
        </div>
        {this.renderDetailed()}
      </div>
    );
  }
  render() {
    return (
      <div>
        {this.renderPhoto()}
        {this.renderProfile()}
      </div>
    );
  }
}