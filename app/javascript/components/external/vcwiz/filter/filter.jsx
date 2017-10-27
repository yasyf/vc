import React from 'react';
import FilterPage from './filter_page';

export default class Filter extends React.Component {
  render() {
    return <FilterPage {...this.props} />;
  }
}