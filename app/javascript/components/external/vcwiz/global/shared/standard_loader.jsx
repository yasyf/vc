import React from 'react';
import Loader from './loader';

export default class StandardLoader extends React.Component {
  static defaultProps = {
    size: 25,
    infoTag: 'h3',
    text: "Loading",
    isLoading: true,
  };

  render() {
    const { size, text, isLoading, infoTag } = this.props;
    if (!isLoading) {
      return null;
    }
    const InfoTag = infoTag;
    return (
      <div className="standard-loader">
        <div className="loader">
          <InfoTag className="loading-text">{text}</InfoTag>
          <Loader spinner="BeatLoader" size={size} />
        </div>
      </div>
    );
  }
}