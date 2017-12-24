import React from 'react';
import classNames from 'classnames';

export default class ModalPage extends React.Component {
  render() {
    const { top, bottom, name } = this.props;
    const wrappedTop = top && (
      <div className={classNames('modal-page-top', `${name}-modal-top`)}>
        {top}
      </div>
    );
    const wrappedBottom = bottom && (
      <div className={classNames('modal-page-bottom', `${name}-modal-bottom`)}>
        {bottom}
      </div>
    );
    return (
      <div className={classNames('overlay-modal-wrapper', `${name}-modal-wrapper`, `${name}-modal-page-wrapper`)}>
        <div className={classNames('modal-page', `${name}-modal`)}>
          {wrappedTop || null}
          {wrappedBottom || null}
        </div>
      </div>
    );
  }
}