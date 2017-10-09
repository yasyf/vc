import React from 'react';
import VCWiz from '../vcwiz';
import FilterPage from './filter_page';

export default class Filter extends React.Component {
  render() {
    return (
      <VCWiz page="filter">
        <FilterPage
          count={this.props.count}
          competitors={this.props.competitors}
          filters={this.props.filters}
        />
      </VCWiz>
    )
  }
}