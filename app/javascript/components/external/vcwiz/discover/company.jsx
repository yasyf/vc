import React from 'react';
import Labels from '../global/shared/labels';
import {CompetitorIndustries} from '../global/constants.js.erb';
import Highlighter from 'react-highlight-words';
import Truncate from 'react-truncate';

export default class Company extends React.Component {
  static defaultProps = {
    lines: 2,
    imgSize: 25,
  };

  render() {
    let image = this.props.domain && <img src={`//logo.clearbit.com/${this.props.domain}?size=${this.props.imgSize}`} />;
    return (
      <div className="company-container">
        <p className="company-name">
          {image}
          {' '}
          <Highlighter
            highlightClassName='highlighter'
            searchWords={[this.props.input]}
            textToHighlight={this.props.name}
          />
        </p>
        <p>
          <Labels items={this.props.industry} extraClass="small" translate={CompetitorIndustries} />
        </p>
        <p>
          <Truncate lines={this.props.lines}>
            {this.props.description}
          </Truncate>
        </p>
      </div>
    );
  }
}