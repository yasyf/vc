import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import {Picker} from 'emoji-mart';

export default class EmojiModal extends OverlayModal {
  static defaultProps = {
    className: 'no-background',
  };

  onEmoji = emoji => {
    console.log(emoji);
    this.props.onClose();
  };

  renderModal() {
    return (
      <div className="emoji-modal">
        <Picker
          set="twitter"
          color="#2ADBC4"
          emoji="exclamation"
          title="Pick Emoji"
          emojiSize={32}
          perLine={10}
          showPreview={true}
          onClick={this.onEmoji}
        />
      </div>
    )
  }
}