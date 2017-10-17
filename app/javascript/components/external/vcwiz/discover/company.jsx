import React from 'react';
import Labels from '../global/shared/labels';
import {CompetitorIndustries} from '../global/constants.js.erb';
import Highlighter from 'react-highlight-words';
import Truncate from 'react-truncate';

class CompanyImage extends React.Component {
  static defaultProps = {
    fallback: 'https://angel.co/images/shared/nopic_startup.png',
  };

  constructor(props) {
    super(props);

    this.state = {
      errored: false,
    };
  }

  onError  = () => {
    this.setState({errored: true});
  };

  render() {
    const { domain, size, fallback } = this.props;
    const style = { height: size, width: size };

    if (this.state.errored || !domain) {
      return fallback ? <img src={fallback} style={style} /> : null;
    }
    return (
      <img
        src={`//logo.clearbit.com/${domain}?size=${size}`}
        onError={this.onError}
        style={style}
      />
    );
  }
}

export default class Company extends React.Component {
  static defaultProps = {
    lines: 2,
    imgSize: 25,
  };

  render() {
    const highlighted = (<Highlighter
      highlightClassName='highlighter'
      searchWords={[this.props.input]}
      textToHighlight={this.props.name}
    />);

    return (
      <div className="company-container">
        <p className="company-name">
          {<CompanyImage fallback={this.props.fallback} domain={this.props.domain} size={this.props.imgSize} />}
          {' '}
          {this.props.website ? <a href={this.props.website} target="_blank">{highlighted}</a> : highlighted}
          {' '}
          <Labels items={this.props.industry} extraClass="small" translate={CompetitorIndustries} />
        </p>
        <p className="company-description">
          <Truncate lines={this.props.lines}>
            {this.props.description}
          </Truncate>
        </p>
      </div>
    );
  }
}