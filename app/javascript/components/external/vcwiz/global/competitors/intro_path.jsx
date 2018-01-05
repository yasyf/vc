import React from 'react';
import {fullName, initials, withSeparators} from '../utils';
import ProfileImage from '../shared/profile_image';
import classNames from 'classnames';

export default class IntroPath extends React.Component {
  static defaultProps = {
    short: false,
  };
  
  renderLink(person) {
    const { short } = this.props;
    const { first_name, email, linkedin } = person;
    const href = linkedin ? `https://linkedin.com/in/${linkedin}` : `mailto:${email}?subject=Intro to ${fullName(person)}`;
    return <a target="_blank" href={href}>{short ? first_name : fullName(person)}</a>;
  }

  renderPerson = (person, i) => {
    const { photo } = person;
    return [
      <div key={`image-${i}`}><ProfileImage fallback={initials(person)} src={photo} size={25} /></div>,
      <div key={`link-${i}`}>{this.renderLink(person)}</div>
    ];
  };

  renderPath() {
    const { path, short } = this.props;
    const { first_hop_via, through } = path;

    if (through.length === 1) {
      return _.compact([
        short ? null : <div key="info">You're connected to</div>,
        <div key="link">{this.renderLink(through[0])}</div>,
        <div key="via">by {first_hop_via}{short ? '' : '.'}</div>,
      ]);
    } else {
      return withSeparators(i => <div key={`arr-${i}`}>&rarr;</div>, through.map(this.renderPerson));
    }
  }

  render() {
    const { path } = this.props;
    const { through } = path;
    if (_.isEmpty(path)) {
      return null;
    }
    return (
      <div className={classNames('intro-path', through.length > 1 ? 'indirect' : 'direct')}>
        {this.renderPath()}
      </div>
    );
  }
}