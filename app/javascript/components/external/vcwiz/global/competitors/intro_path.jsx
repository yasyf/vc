import React from 'react';
import {fullName, initials, withSeparators} from '../utils';
import ProfileImage from '../shared/profile_image';
import classNames from 'classnames';

export default class IntroPath extends React.Component {
  static defaultProps = {
    short: false,
    hidePhotos: false,
  };
  
  renderLink(person) {
    const { short } = this.props;
    const { first_name, email, linkedin, twitter } = person;
    const href = _.first(_.compact([
      linkedin && `https://linkedin.com/in/${linkedin}`,
      email && `mailto:${email}`,
      twitter && `https://twitter.com/${twitter}`,
    ]));
    if (href) {
      return <a target="_blank" href={href}>{short ? first_name : fullName(person)}</a>;
    } else {
      return short ? first_name : fullName(person);
    }
  }

  renderPerson = (person, i) => {
    if (_.isString(person)) {
      return <div key={`link-${i}`}>person</div>;
    }
    const { hidePhotos } = this.props;
    const { photo } = person;
    return _.compact([
      hidePhotos ? null : <div key={`image-${i}`}><ProfileImage fallback={initials(person)} src={photo} size={25} /></div>,
      <div key={`link-${i}`}>{this.renderLink(person)}</div>
    ]);
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
      const show = short ? (through.length === 2 ? through : [_.first(through), '...', _.last(through)]) : through;
      return withSeparators(i => <div key={`arr-${i}`}>&rarr;</div>, show.map(this.renderPerson));
    }
  }

  renderFull() {
    const { short } = this.props;
    return _.compact([
      short ? null : <div key="link-text" className="link">Link:</div>,
      ...this.renderPath(),
    ]);
  }

  render() {
    const { path, hidePhotos } = this.props;
    if (_.isEmpty(path)) {
      return null;
    }
    const { through } = path;
    return (
      <div className={classNames('intro-path', through.length > 1 ? 'indirect' : 'direct', hidePhotos ? 'without-photos' : 'with-photos')}>
        {this.renderFull()}
      </div>
    );
  }
}