import React from 'react';
import VCWiz  from '../vcwiz';

export default class Warmup extends React.Component {
  render() {
    return (
      <VCWiz
        page="warmup"
        header="Hello, World!"
        body="Welcome to VCWiz!"
        showIntro={true}
      />
    );
  }
}