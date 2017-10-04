import React from 'react';
import Header from './global/header';
import SearchHero from './discover/search_hero';

export default class VCWiz extends React.Component {
  render() {
    return (
      <div id="vcwiz">
        <Header />
        <SearchHero />
      </div>
    )
  }
}