import React from 'react';
import Modal from 'react-modal';
import classNames from 'classnames';

export default class OverlayModal extends React.Component {
  static defaultProps = {
    isOpen: true,
  };

  renderModal() {
    const { top, bottom, name } = this.props;
    let wrappedTop = top && (
      <div className={classNames('overlay-modal-top', `${name}-modal-top`)}>
        {top}
      </div>
    );
    let wrappedBottom = bottom && (
      <div className={classNames('overlay-modal-bottom', `${name}-modal-bottom`)}>
        {bottom}
      </div>
    );
    return (
      <div className={classNames('overlay-modal', `${name}-modal`)}>
        {wrappedTop || null}
        {wrappedBottom || null}
      </div>
    )
  }

  render() {
    const { name, modal, isOpen, onClose, className } = this.props;
    if (!isOpen) {
      return null;
    }
    return (
      <Modal
        isOpen={isOpen}
        onRequestClose={onClose}
        contentLabel={name}
        overlayClassName="modal-overlay"
        className={classNames('modal-content', className)}
      >
        {modal ? modal : this.renderModal()}
      </Modal>
    )
  }
}