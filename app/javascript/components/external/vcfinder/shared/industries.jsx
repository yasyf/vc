import React  from 'react';
import {CompetitorIndustries} from '../constants.js.erb';

export default class Industries extends React.Component {
  render() {
    let className = `badge ${this.props.extraClass || ''}`;
    let nodes = this.props.industry.map(i =>
      <span className={className} key={i}>{this.props.translate[i] || i}</span>
    );
    return <span>{nodes}</span>;
  }
}

Industries.defaultProps = {
  translate: CompetitorIndustries,
};