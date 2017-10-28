import React from 'react';
import Header from './global/shared/header';
import classNames from 'classnames';
import {withDims} from './global/utils';

class VCWizBody extends React.Component {
  render() {
    const {page, children, containerWidth, containerHeight} = this.props;
    let element = React.Children.only(children);
    const style = {width: containerWidth, height: containerHeight, ...element.props.style};
    return React.cloneElement(element, {style});
  }
}
const VCWizBodyWithDims = withDims(VCWizBody);


export default class VCWiz extends React.Component {
  static defaultProps = {
    header: null,
    modal: null,
    wrapBody: true,
  };

  render() {
    const { page, wrapBody } = this.props;
    const header = this.props.header && (
      <div className={classNames('vcwiz-header', `${page}-page-header`)}>
        {this.props.header}
      </div>
    );
    const body =
      wrapBody
        ? <VCWizBodyWithDims page={page}>{this.props.body}</VCWizBodyWithDims>
        : this.props.body
    ;
    return (
      <div id="vcwiz" className={classNames('full-screen', 'vcwiz', `toplevel-${page}-page`)}>
        <Header />
        <div className={classNames('vcwiz-page', `${page}-page`)}>
          {header || null}
          <div className={classNames('vcwiz-body', `${page}-page-body`)}>
            {body}
          </div>
        </div>
        {this.props.modal}
      </div>
    )
  }
}