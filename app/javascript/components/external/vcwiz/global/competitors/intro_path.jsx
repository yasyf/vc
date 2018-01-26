import React from 'react';
import {fullName, initials, withSeparators} from '../utils';
import ProfileImage from '../shared/profile_image';

export default class IntroPath extends React.Component {
  renderLink(person) {
    const { first_name, email, linkedin, twitter } = person;
    const href = _.first(_.compact([
      linkedin && `https://linkedin.com/in/${linkedin}`,
      email && `mailto:${email}`,
      twitter && `https://twitter.com/${twitter}`,
    ]));
    if (href) {
      return <a target="_blank" href={href} onClick={() => window.open(href)}>{fullName(person)}</a>;
    } else {
      return fullName(person);
    }
  }

  renderPerson = (person, i) => {
    if (_.isString(person)) {
      return <div key={`link-${i}`}>{person}</div>;
    }
    const { photo } = person;
    return _.compact([
      <div key={`image-${i}`}><ProfileImage fallback={initials(person)} src={photo} size={50} /></div>,
      <div key={`link-${i}`}>{this.renderLink(person)}</div>,
    ]);
  };

  renderPath() {
    const { path } = this.props;
    const { first_hop_via, through } = path;

    return withSeparators(i => <div key={`arr-${i}`}>&rarr;</div>, through.map(this.renderPerson));
  }

  render() {
    const { path } = this.props;
    if (_.isEmpty(path)) {
      return null;
    }
    return (
      <div className="intro-path">
        {this.renderPath()}
      </div>
    );
  }
}