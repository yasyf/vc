import React from 'react';
import TextCell from './text_cell';
import {Emoji} from 'emoji-mart';

export default class EmojiCell extends TextCell {
  renderEmoji(name, size = 32) {
    return <Emoji size={size} sheetSize={size} emoji={name} set="twitter" />;
  }

  renderEmojiValue() {
    if (this.state.value) {
      return this.renderEmoji(this.state.value);
    } else {
      return this.renderEmoji('exclamation');
    }
  }

  renderValue() {
    return <div className="emoji-cell">{this.renderEmojiValue()}</div>;
  }
}