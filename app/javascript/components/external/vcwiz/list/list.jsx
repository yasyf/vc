import React from 'react';
import VCWiz from '../vcwiz';
import ListPage from './list_page';

export default class List extends React.Component {
  render() {
    let { list } = this.props;
    return (
      <VCWiz page="list">
        <ListPage {...list} />
      </VCWiz>
    )
  }
}