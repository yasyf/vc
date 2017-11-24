import React from 'react';
import ListPage from './list_page';

export default class List extends React.Component {
  render() {
    return <ListPage path={this.props.path} {...this.props.list} />;
  }
}