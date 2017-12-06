import React from 'react';
import classNames from 'classnames';

export default class Flash extends React.Component {
  state = {
    closed: false,
  };

  onClose = () => {
    this.setState({closed: true});
  };

  render() {
    const { type, message } = this.props;
    const { closed } = this.state;

    if (closed) {
      return null;
    }
    return (
      <div className={classNames('callout', type)}>
        <h5>{message}</h5>
        <button className="close-button" aria-label="Dismiss alert" type="button" onClick={this.onClose}>
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    );
  }
}