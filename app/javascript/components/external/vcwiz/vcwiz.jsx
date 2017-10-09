import React from 'react';
import Header from './global/shared/header';
import classNames from 'classnames';

export default class VCWiz extends React.Component {
  render() {
    return (
      <div id="vcwiz" className={classNames('full-screen', `toplevel-${this.props.page}-page`)}>
        <Header />
        {this.props.children}
      </div>
    )
  }
}