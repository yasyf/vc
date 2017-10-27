import React from 'react';
import Header from './global/shared/header';
import classNames from 'classnames';

export default class VCWiz extends React.Component {
  static defaultProps = {
    modal: null,
  };

  render() {
    const { page } = this.props;
    return (
      <div id="vcwiz" className={classNames('full-screen', `toplevel-${page}-page`)}>
        <Header />
        <div className={classNames('full-screen', `${page}-page`)}>
          <div className={`${page}-page-header`}>
            {this.props.header}
          </div>
          <div className={classNames('full-screen', `${page}-page-body`)}>
            {this.props.body}
          </div>
        </div>
        {this.props.modal}
      </div>
    )
  }
}