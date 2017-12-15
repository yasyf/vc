import React from 'react';
import classNames from 'classnames';

export default class Flash extends React.Component {
  static defaultProps = {
    showClose: true
  };

  state = {
    closed: false,
  };

  onClose = () => {
    this.setState({closed: true});
    this.props.onClose();
  };

  onClick = () => {
    const { link } = this.props;
    if (!link) {
      this.onClose();
    } else {
      window.location.href = link;
    }
  };

  renderCloseButton() {
    if (!this.props.showClose) {
      return null;
    }
    return (
      <button className="close-button" aria-label="Dismiss alert" type="button" onClick={this.onClose}>
        <span aria-hidden="true">&times;</span>
      </button>
    );
  }

  render() {
    const { type, message, link } = this.props;
    const { closed } = this.state;

    if (closed) {
      return null;
    }
    return (
      <div className={classNames('callout', type)}>
        <div onClick={this.onClick}>{message}</div>
        {this.renderCloseButton()}
      </div>
    );
  }
}