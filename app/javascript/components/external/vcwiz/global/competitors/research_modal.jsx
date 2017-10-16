import React from 'react';
import Modal from 'react-modal';

export default class ResearchModal extends React.Component {
  renderModal() {
    const { name } = this.props;
    return (
      <div>
        <div>
          <h3>{name}</h3>
        </div>
      </div>
    )
  }

  render() {
    const { name, onClose } = this.props;
    return (
      <Modal
        isOpen={true}
        onRequestClose={onClose}
        contentLabel={name}
        overlayClassName="modal-overlay"
        className="modal-content"
      >
        {this.renderModal()}
      </Modal>
    )
  }
}