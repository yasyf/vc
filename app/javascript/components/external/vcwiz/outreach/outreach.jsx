import React from 'react';
import OutreachPage from './outreach_page';
import { Emoji } from 'emoji-mart'
import { canUseDOM } from 'exenv';
import {preloadImage} from '../global/utils';

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
      sizes.forEach(size => preloadImage(Emoji.defaultProps.backgroundImageFn(set, size)));
    });
  }

  render() {
    return (
      <OutreachPage {...this.props} />
    )
  }
}