import React from 'react';
import Modal from 'react-modal';
import classNames from 'classnames';
import inflection from 'inflection';

export default class OverlayModal extends React.Component {
  renderModal() {
    let displayName = inflection.underscore(this.constructor.name.slice(0, -5));

    let top = this.renderTop();
    let wrappedTop = top && (
      <div className={classNames('overlay-modal-top', `${displayName}-modal-top`)}>
        {top}
      </div>
    );

    let bottom = this.renderBottom();
    let wrappedBottom = bottom && (
      <div className={classNames('overlay-modal-bottom', `${displayName}-modal-bottom`)}>
        {bottom}
      </div>
    );
    return (
      <div className={classNames('overlay-modal', `${displayName}-modal`)}>
        {wrappedTop || null}
        {wrappedBottom || null}
      </div>
    )
  }

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