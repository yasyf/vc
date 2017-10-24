import React from 'react';
import Modal from 'react-modal';
import classNames from 'classnames';

export default class OverlayModal extends React.Component {
  render() {
    const { name, onClose, className } = this.props;
    return (
      <Modal
        isOpen={true}
        onRequestClose={onClose}
        contentLabel={name}
        overlayClassName="modal-overlay"
        className={classNames('modal-content', className)}
      >
        {this.renderModal()}
      </Modal>
    )
  }
}