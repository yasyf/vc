import React from 'react';
import Header from './global/shared/header';

export default class VCWiz extends React.Component {
  render() {
    return (
      <div id="vcwiz" className='full-screen'>
        <Header />
        {this.props.children}
      </div>
    )
  }
}