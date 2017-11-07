import React from 'react';
import Header from './global/shared/header';
import classNames from 'classnames';
import {withDims, currentPage, isLoggedIn} from './global/utils';
import Store from './global/store';
import Storage from './global/storage.js.erb';
import {StorageRestoreStateKey} from './global/constants.js.erb';
import { canUseDOM } from 'exenv';
import {Column, Row} from 'react-foundation';
import Sidebar from './global/shared/sidebar';

class VCWizBody extends React.Component {
  render() {
    const {page, children, containerWidth, containerHeight, dimensionsKey} = this.props;
    let element = React.Children.only(children);
    const dimensions = {width: containerWidth, height: containerHeight};
    const style = {...element.props.style, ...dimensions};
    if (dimensionsKey) {
      Store.set(dimensionsKey, dimensions);
    }
    return React.cloneElement(element, {style});
  }
}
const VCWizBodyWithDims = withDims(VCWizBody);


export default class VCWiz extends React.Component {
  static defaultProps = {
    header: null,
    modal: null,
    wrapBody: true,
    showSidebar: false,
  };

  componentWillMount() {
    if (!canUseDOM) {
      return;
    }
    const restoreState = Storage.get(StorageRestoreStateKey);
    if (restoreState) {
      if (currentPage() !== restoreState.location) {
        window.location = restoreState.location;
      } else {
        Storage.remove(StorageRestoreStateKey);
        Store.set(StorageRestoreStateKey, restoreState);
      }
    }
  }

  renderBody() {
    const { page, wrapBody, showSidebar, body } = this.props;
    const wrappedBody = (
      wrapBody
        ? <VCWizBodyWithDims dimensionsKey="dimensions">{body}</VCWizBodyWithDims>
        : body
    );
    const withSidebar = isLoggedIn() && showSidebar ? (
      <Row className="full-max-width">
        <Column className="full-height sidebar-column" large={3}>{<Sidebar />}</Column>
        <Column className="full-height" large={9}>{wrappedBody}</Column>
      </Row>
    ) : (
      <div>
        {wrappedBody}
      </div>
    );
    return <VCWizBodyWithDims dimensionsKey="windowDimensions">{withSidebar}</VCWizBodyWithDims>;
  }

  render() {
    const { page, wrapBody } = this.props;
    const header = this.props.header && (
      <div className={classNames('vcwiz-header', `${page}-page-header`)}>
        {this.props.header}
      </div>
    );
    return (
      <div id="vcwiz" className={classNames('full-screen', 'vcwiz', `toplevel-${page}-page`)}>
        <Header />
        <div className={classNames('vcwiz-page', `${page}-page`)}>
          {header || null}
          <div className={classNames('vcwiz-body', `${page}-page-body`)}>
            {this.renderBody()}
          </div>
        </div>
        {this.props.modal}
      </div>
    );
  }
}