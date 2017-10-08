import React from 'react';
import VCWiz from '../vcwiz';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath} from '../global/constants.js.erb';

export default class Filter extends React.Component {
  render() {
    return (
      <VCWiz>
        <Results
          count={this.props.count}
          competitors={this.props.competitors}
          path={CompetitorsFilterPath}
        />
      </VCWiz>
    )
  }
}