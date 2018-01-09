import React from 'react';
import {humanizeList, initials} from '../utils';
import ProfileImage from '../shared/profile_image';
import IntroPathModal from './intro_path_modal';

export default class IntroPathCount extends React.Component {
  static defaultProps = {
    short: false,
  };

  state = {
    modalOpen: false
  };

  openModal = e => {
    e.preventDefault();
    e.stopPropagation();
    this.setState({modalOpen: true});
  };

  closeModal = () => this.setState({modalOpen: false});

  renderPerson = (person, i) => {
    const { short } = this.props;
    const { photo, first_name } = person;
    return _.compact([
      short ? null : <div key={`image-${i}`}><ProfileImage fallback={initials(person)} src={photo} size={25} /></div>,
      <div key={`link-${i}`}>{first_name}</div>
    ]);
  };

  renderCount() {
    const { direct, count, nodes, short, first_hop_via } = this.props;
    if (!count) {
      return null;
    }
    const show = _.take(nodes, 2);
    const remaining = nodes.length - show.length;
    if (direct) {
      return _.compact([
        <div key="pre">You're connected{short ? '' : ' directly'} to</div>,
        ...humanizeList(show.map(this.renderPerson)),
        remaining ? <div key="post">and {remaining} others</div> : null,
      ]);
    } else {
      return _.compact([
        ...humanizeList(show.map(this.renderPerson)),
        remaining ? <div key="post">and {remaining} others</div> : null,
        <div key="post2">can introduce you</div>,
      ]);
    }
  }

  renderMore() {
    const { direct, count, short } = this.props;
    if (!count || direct) {
      return false;
    }
    return (
      <div>
        <a>{short ? <span>&rarr;</span> : <span>See all paths &rarr;</span>}</a>
      </div>
    )
  }

  renderModal() {
    const { modalOpen } = this.state;
    if (!modalOpen) {
      return null;
    }
    return <IntroPathModal onClose={this.closeModal} {...this.props} />;
  }

  render() {
    return (
      <div>
        <div className="intro-path-count" onClick={this.openModal}>
          {this.renderCount()}
          {this.renderMore()}
        </div>
        {this.renderModal()}
      </div>
    );
  }
}