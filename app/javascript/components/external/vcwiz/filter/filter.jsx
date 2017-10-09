import React from 'react';
import VCWiz from '../vcwiz';
import FilterPage from '../global/filter_page';
import Results from '../global/competitors/results';
import {CompetitorsFilterPath} from '../global/constants.js.erb';

export default class Filter extends React.Component {
  render() {
    return (
      <VCWiz page="filter">
        <FilterPage>
          <Results
            count={this.props.count}
            competitors={this.props.competitors}
            path={CompetitorsFilterPath}
          />
        </FilterPage>
      </VCWiz>
    )
  }
}