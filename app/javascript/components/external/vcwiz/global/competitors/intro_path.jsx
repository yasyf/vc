import React from 'react';

export default class IntroPath extends React.Component {
  static defaultProps = {
    fullSentence: true,
  };

  renderStart() {
    const { path, displayName, fullSentence } = this.props;
    const { direct, first_hop_via, through } = path;

    if (!fullSentence) {
      return '';
    }

    if (direct) {
      return `You are connected with ${displayName} `;
    } else {
      return `You have a connection to ${displayName} `;
    }
  }

  renderLink() {
    const { path, fullName } = this.props;
    const { through } = path;
    const { name, email, linkedin } = through[0];
    const href = linkedin ? `https://linkedin.com/in/${linkedin}` : `mailto:${email}?subject=Intro to ${fullName}`;
    return <a target="_blank" href={href}>{name}</a>;
  }

  renderMiddle() {
    const { path, fullName, fullSentence } = this.props;
    const { direct, first_hop_via, through } = path;

    if (direct) {
      return <span key="middle">by {first_hop_via}</span>;
    } else if (through.length === 1) {
      return <span key="middle">through {this.renderLink()}</span>;
    } else if (through.length === 2) {

      const lastName = through[1].name;
      return <span key="middle">through {lastName}, via {this.renderLink()}</span>;
    } else {
      const middleName = through[1].name;
      const lastParts = through[2].name.split(' ');
      const lastName = `${_.head(lastParts)} ${_.tail(lastParts).map(s => `${_.first(s)}.`).join(' ')}`;
      return <span key="middle">through {middleName} and {lastName}, via {this.renderLink()}</span>;
    }
  }

  renderEnd() {
    const { fullSentence } = this.props;
    if (!fullSentence) {
      return '';
    }
    return '.';
  }

  render() {
    const { path, name } = this.props;
    if (_.isEmpty(path)) {
      return null;
    }
    return [
      <span key="start">{this.renderStart()}</span>,
      this.renderMiddle(),
      <span key="end">{this.renderEnd()}</span>,
    ];
  }
}