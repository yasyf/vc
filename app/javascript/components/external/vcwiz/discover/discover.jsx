import React from 'react';
import VCWiz from '../vcwiz';
import SearchHero from './search_hero';

export default class Discovery extends React.Component {
  render() {
    return (
      <VCWiz>
        <SearchHero />
      </VCWiz>
    )
  }
}