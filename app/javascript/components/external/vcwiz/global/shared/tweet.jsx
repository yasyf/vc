import React from 'react';
import Linkify from 'linkifyjs/react';
import moment from 'moment';

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

export default class Tweet extends React.Component {
  render() {
    return (
      <div className="tweet">
        <i className="line-icon fi-social-twitter"/>
        <Linkify options={linkifyOptions}>&ldquo;{this.props.tweet.text}&rdquo;</Linkify>
        <span className="dot">-</span>
        <span className="faded">{moment(this.props.tweet.tweeted_at).fromNow()}</span>
      </div>
    );
  }
}