import React  from 'react';
import {CompetitorIndustries} from '../constants.js.erb';

export default class Industries extends React.Component {
  render() {
    let {industry, translate, extraClass} = this.props;

    if (!industry) {
      return null;
    }

    let className = `badge ${extraClass || ''}`;
    let nodes = industry.map(i =>
      <span className={className} key={i}>{translate[i] || i}</span>
    );
    return <span>{nodes}</span>;
  }
}

Industries.defaultProps = {
  translate: CompetitorIndustries,
};