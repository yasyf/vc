import React from 'react';
import Header from './global/shared/header';
import classNames from 'classnames';

export default class VCWiz extends React.Component {
  static defaultProps = {
    header: null,
    modal: null,
  };

  render() {
    const { page } = this.props;
    const header = this.props.header && (
      <div className={classNames('vcwiz-header', `${page}-page-header`)}>
        {this.props.header}
      </div>
    );
    return (
      <div id="vcwiz" className={classNames('full-screen', 'vcwiz', `toplevel-${page}-page`)}>
        <Header />
        <div className={classNames('full-screen', 'vcwiz-page', `${page}-page`)}>
          {header || null}
          <div className={classNames('full-screen', 'vcwiz-body', `${page}-page-body`)}>
            {this.props.body}
          </div>
        </div>
        {this.props.modal}
      </div>
    )
  }
}