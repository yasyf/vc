import React from 'react';
import VCWiz from '../vcwiz';
import SearchHero from './search_hero';
import Lists from './lists';

export default class Discovery extends React.Component {
  render() {
    return (
      <VCWiz page="discover">
        <div className="discover-page-header">
          <SearchHero />
        </div>
        <div className="discover-page-body full-screen">
          <Lists />
        </div>
      </VCWiz>
    )
  }
}