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
  dots: true,
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

  onCancel = () => {
    this.props.onClose(false);
  };

  onAdd = () => {
    this.props.onClose(true, this.props.investor);
  };

  renderPhoto() {
    if (this.state.investor.photo) {
      return <img src={this.state.investor.photo} />;
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
      dots: false,
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
        <hr/>
        <div className="row">
          <div className="small-12 columns">
            <h4>Blog Posts</h4>
            {posts}
          </div>
        </div>
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
        <div className="pad-vert-less">
          <Slider {...sliderSettings}>
            {recents}
          </Slider>
        </div>
      </div>
    );
  }

  renderRecentInvestmentsContainer(fullWidth) {
    if (!this.state.investor.competitor.recent_investments.length) {
      return null;
    }
    let className = "small-6 medium-8 large-7 columns";
    if (fullWidth) {
      className = "small-12 columns";
    }
    return (
      <div className={className}>
        {this.renderRecentInvestments()}
      </div>
    );
  }

  renderBasic() {
    let {role, competitor} = this.state.investor;
    return (
      <div className="float-center text-center">
        {this.renderPhoto()}
        <h3>{fullName(this.state.investor)}</h3>
        <h4>{role ? `${role}, ` : ''}{competitor.name}</h4>
      </div>
    );
  }

  renderSocial() {
    let {
      location,
      facebook,
      twitter,
      linkedin,
    } = this.state.investor;

    return (
      <div>
        <h4>Social</h4>
        {this.renderIconLine('home', location)}
        {this.renderIconLine('social-facebook', facebook, 'https://fb.com')}
        {this.renderIconLine('social-twitter', twitter, 'https://twitter.com')}
        {this.renderIconLine('social-linkedin', linkedin, 'https://linkedin.com/in')}
        {this.renderHomepage()}
      </div>
    );
  }

  renderSocialContainer() {
    let {
      location,
      facebook,
      twitter,
      linkedin,
    } = this.state.investor;
    if (!_.some([location, facebook, twitter, linkedin])) {
      return null;
    }
    return (
      <div className="small-6 medium-4 large-5 columns">
        {this.renderSocial()}
      </div>
    );
  }

  renderDescriptions() {
    let {competitor, description} = this.state.investor;
    return (
      <div className="row">
        <div className="small-6 large-12 columns">
          <p><ReadMore>{competitor.description}</ReadMore></p>
        </div>
        <div className="small-6 large-12 columns">
          <p><ReadMore>{description}</ReadMore></p>
        </div>
      </div>
    );
  }

  renderButtons() {
    return (
      <div className="row">
        <div className="small-12 columns">
          <button type="button" className="button full-button" onClick={this.onAdd}>
            Add To List
          </button>
        </div>
      </div>
    );
  }

  renderSocialAndInvestments() {
    let social = this.renderSocialContainer();
    let investments = this.renderRecentInvestmentsContainer(!social);
    if (!social && !investments) {
      return null;
    }
    return (
      <div>
        <hr className="hide-for-large"/>
        <div className="row">
          {social}
          {investments}
        </div>
      </div>
    );
  }

  renderProfile() {
    if (!this.state.loaded) {
      return (
        <div>
          {this.renderBasic()}
          <div className="text-center">Loading...</div>
        </div>
      );
    }

    return (
      <div>
        <div className="row">
          <div className="small-12 large-6 columns">
            <div className="float-center text-center">
              {this.renderBasic()}
              {this.renderIndustries()}
              {this.renderTweets()}
            </div>
          </div>
          <div className="small-12 large-6 columns">
            {this.renderSocialAndInvestments()}
            {this.renderPosts()}
          </div>
        </div>
        <hr/>
        {this.renderDescriptions()}
        <hr/>
        {this.renderButtons()}
      </div>
    );
  }

  render() {
    return this.renderProfile();
  }
}