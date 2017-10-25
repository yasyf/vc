import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import {Picker} from 'emoji-mart';

export default class EmojiModal extends OverlayModal {
  static defaultProps = {
    className: 'no-background',
  };

  onEmoji = emoji => {
    this.props.onResult({[this.props.rowKey]: emoji.colons});
  };

  renderModal() {
    return (
      <div className="emoji-modal">
        <Picker
          set="twitter"
          color="#2ADBC4"
          emoji={this.props.item[this.props.rowKey] || 'exclamation'}
          title="Pick Emoji"
          sheetSize={32}
          emojiSize={32}
          perLine={10}
          showPreview={true}
          onClick={this.onEmoji}
        />
      </div>
    )
  }
}