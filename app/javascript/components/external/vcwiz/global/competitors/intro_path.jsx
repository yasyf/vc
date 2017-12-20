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

  renderMiddle() {
    const { path, fullName, fullSentence } = this.props;
    const { direct, first_hop_via, through } = path;

    if (direct) {
      return `by ${first_hop_via}`;
    } else if (through.length === 1) {
      const { name, email } = through[0];
      const link = <a target="_blank" href={`mailto:${email}?subject=Intro to ${fullName}`}>{name}</a>;
      return `through ${link}`;
    } else if (through.length === 2) {
      const { name, email } = through[0];
      const link = <a target="_blank" href={`mailto:${email}?subject=Intro to ${fullName}`}>{name}</a>;
      const lastName = through[1].name;
      return `through ${lastName}, via ${link}`;
    } else {
      const { name, email } = through[0];
      const link = <a target="_blank" href={`mailto:${email}?subject=Intro to ${fullName}`}>{name}</a>;
      const middleName = through[1].name;
      const lastParts = through[2].name.split(' ');
      const lastName = `${_.head(lastParts)} ${_.tail(lastParts).map(s => `${_.first(s)}.`).join(' ')}`;
      return `through ${middleName} and ${lastName}, via ${link}`;
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
    if (!path) {
      return null;
    }
    return `${this.renderStart()}${this.renderMiddle()}${this.renderEnd()}`;
  }
}