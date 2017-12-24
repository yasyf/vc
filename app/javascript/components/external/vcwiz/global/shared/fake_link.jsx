import React from 'react';

export default class FakeLink extends React.Component {
  onLinkClick = e => e.preventDefault();

  render() {
    const { href, value } = this.props;
    return (
      <a href={href} className="indistinguishable" onClick={this.onLinkClick}>{value}</a>
    );
  }
}