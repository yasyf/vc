import React from 'react';
import VCWiz from '../vcwiz';
import Conversations from './conversations';

export default class Outreach extends React.Component {
  render() {
    return (
      <VCWiz page="outreach">
        <div className="outreach-page-body full-screen">
          <Conversations {...this.props} />
        </div>
      </VCWiz>
    )
  }
}