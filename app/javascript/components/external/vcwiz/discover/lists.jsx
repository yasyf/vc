import React from 'react';
import { RingLoader as Loader } from 'react-spinners';
import { CompetitorsListsPath } from '../global/constants.js.erb'
import { ffetch } from '../global/utils';
import ProfileImage from '../global/shared/profile_image';

export default class Lists extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      lists: [],
    };
  }

  componentDidMount() {
    ffetch(CompetitorsListsPath).then(lists => {
      this.setState({lists, loading: false});
    });
  }

  profileImageProps() {
    return {
      className: 'inline-image',
      size: 45,
    };
  }

  renderLoading() {
    return (
      <div className="text-center loading">
        <Loader color="#2ADBC4" size={200} />
      </div>
    );
  }

  renderCount(count) {
    return <ProfileImage fallback={`+${count}`} {...this.profileImageProps()} />;
  }

  renderCompetitor = ({id, photo, acronym}) => {
    return (
      <ProfileImage
        key={id}
        src={photo}
        fallback={acronym}
        {...this.profileImageProps()}
      />
    );
  };

  renderList = ({title, name, competitors, count}) => {
    return (
      <div className="card" key={name}>
        <div className="card-section">
          <p className="title">{title}</p>
          <h6>Investors</h6>
          {competitors.map(this.renderCompetitor)}
          {this.renderCount(count)}
        </div>
      </div>
    );
  };

  renderLists() {
    return (
      <div className="cards">
        {this.state.lists.map(this.renderList)}
      </div>
    );
  }

  render() {
    if (this.state.loading) {
      return this.renderLoading();
    } else {
      return this.renderLists();
    }
  }
}