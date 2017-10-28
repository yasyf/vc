import React from 'react';
import VCWiz from '../vcwiz';
import SearchHero from './search_hero';
import Lists from './lists';

export default class Discovery extends React.Component {
  render() {
    return (
      <VCWiz
        page="discover"
        header={<SearchHero />}
        body={<Lists />}
        wrapBody={false}
      />
    );
  }
}