import React from 'react';
import moment from 'moment';

// Linkify Options
import * as linkify from 'linkifyjs';
import hashtag from 'linkifyjs/plugins/hashtag';
import mention from 'linkifyjs/plugins/mention';
hashtag(linkify);
mention(linkify);
import linkifyHtml from 'linkifyjs/html';
// --

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
        &ldquo;<span dangerouslySetInnerHTML={{ __html: linkifyHtml(this.props.tweet.text, linkifyOptions) }} />&rdquo;
        <span className="dot">-</span>
        <span className="faded">{moment(this.props.tweet.tweeted_at).fromNow()}</span>
      </div>
    );
  }
}