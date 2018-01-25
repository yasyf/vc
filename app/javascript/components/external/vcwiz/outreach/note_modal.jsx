import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import TextArea from '../global/fields/text_area';

export default class NoteModal extends React.Component {
  onChange = update => {
    this.props.onResult(update, true);
  };

  renderModal() {
    return (
      <div className="note-modal">
        <TextArea
          value={this.props.item[this.props.rowKey]}
          name={this.props.rowKey}
          wrap={false}
          debounced={true}
          inputRef={input => input &&input.focus()}
          onChange={this.onChange}
        />
      </div>
    )
  }

  render() {
    return (
      <OverlayModal
        name="note"
        modal={this.renderModal()}
        {...this.props}
      />
    );
  }
}