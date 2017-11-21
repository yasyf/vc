import React from 'react';
import OutreachPage from './outreach_page';
import { Emoji } from 'emoji-mart'
import { canUseDOM } from 'exenv';

const EmojiSheets = {twitter: [32]};

export default class Outreach extends React.Component {
  componentDidMount() {
    this.preloadSheets();
  }

  preloadSheets() {
    if (!canUseDOM) {
      return;
    }
    Object.entries(EmojiSheets).forEach(([set, sizes]) => {
      sizes.forEach(size => {
        let preload = document.createElement("link");
        preload.href = Emoji.defaultProps.backgroundImageFn(set, size);
        preload.rel = 'preload';
        preload.as = 'image';
        document.head.appendChild(preload);
      });
    });
  }

  render() {
    return (
      <OutreachPage {...this.props} />
    )
  }
}