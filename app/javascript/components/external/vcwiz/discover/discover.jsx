import React from 'react';
import VCWiz  from '../vcwiz';
import Hero from './hero';
import Lists from './lists';

export default class Discovery extends React.Component {
  render() {
    return (
      <VCWiz
        page="discover"
        header={<Hero {...this.props} />}
        body={<Lists />}
        showIntro={true}
      />
    );
  }
}