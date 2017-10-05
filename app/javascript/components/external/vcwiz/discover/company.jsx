import React from 'react';
import Labels from '../global/labels';
import {CompetitorIndustries} from '../global/constants.js.erb';
import Highlighter from 'react-highlight-words';
import Truncate from 'react-truncate';

export default class Company extends React.Component {
  render() {
    let image = this.props.domain && <img src={`//logo.clearbit.com/${this.props.domain}?size=25`} />;
    return (
      <div className="company-container">
        <p>
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
          <Truncate lines={2}>
            {this.props.description}
          </Truncate>
        </p>
      </div>
    );
  }
}