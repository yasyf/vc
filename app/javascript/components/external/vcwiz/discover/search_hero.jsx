import React from 'react';
import Filters from './filters';

export default class SearchHero extends React.Component {
  render() {
    return (
      <div className="text-center search-hero">
        <div className="welcome">
          <h3><b>Discover Seed-Stage Investors</b></h3>
          <p>
            Find the VCs that may be interested in your startup.
            Get introduced, track your conversations, and raise your seed round.
          </p>
        </div>
        <div className="filters">
          <Filters />
        </div>
      </div>
    )
  }
}