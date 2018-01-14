import React from 'react';
import Modal from 'react-modal';
import Header from './global/shared/header';
import classNames from 'classnames';
import {currentPage, ffetch} from './global/utils';
import Store from './global/store';
import Actions from './global/actions';
import {SessionStorage} from './global/storage.js.erb';
import {StorageRestoreStateKey, FounderPath} from './global/constants.js.erb';
import { canUseDOM } from 'exenv';
import Footer from './global/shared/footer';

class GlobalErrorBoundary extends React.Component {
  state = {
    error: null
  };

  componentDidCatch(error, info) {
    this.setState({error});
    Raven.captureException(error, {extra: info});
  }

  onClick = () => Raven.showReportDialog();

  renderDetails() {
    if (Raven.lastEventId()) {
      return (
        <p>
          Our team has already been notified, but we'd appreciate it if you could take 2 minutes to <a onClick={this.onClick}>fill out a crash report</a>.
        </p>
      );
    } else {
      return <p>Our team has been notified. We'll get right on fixing this!</p>;
    }
  }

  renderError() {
    return (
      <div className="global-error" onClick={this.onClick}>
        <h1>Oh no!</h1>
        <p>We're sorry — something's gone wrong.</p>
        {this.renderDetails()}
      </div>
    );
  }

  render() {
    if (this.state.error) {
      return this.renderError();
    } else {
      return this.props.children;
    }
  }
}

export default class VCWiz extends React.Component {
  static defaultProps = {
    header: null,
    modal: null,
    showIntro: false,
    inlineSignup: false,
    isOutreach: false,
    subtitle: 'Raise Your Seed Round',
  };

  onClick = e => {
    Store.set('lastClick', e);
  };

  onScroll = e => {
    Store.set('lastScroll', e);
  };

  componentWillMount() {
    Store.set('founder', window.gon.founder);
    Actions.register('refreshFounder', this.refreshFounder);

    if (!canUseDOM) {
      return;
    }

    window.addEventListener('scroll', this.onScroll, true);

    Store.set('dimensions', {width: document.documentElement.clientWidth, height: document.documentElement.clientHeight});

    const restoreState = SessionStorage.get(StorageRestoreStateKey);
    if (restoreState) {
      if (currentPage() === restoreState.location) {
        SessionStorage.remove(StorageRestoreStateKey);
        Store.set(StorageRestoreStateKey, restoreState);
      }
    }
  }

  componentDidMount() {
    Modal.setAppElement('#vcwiz');
  }

  componentWillUnmount() {
    Actions.unregister('refreshFounder');
  }

  refreshFounder = founder => {
    if (founder) {
      Store.set('founder', founder);
    } else {
      ffetch(FounderPath).then(founder => Store.set('founder', founder));
    }
  };

  renderHeader() {
    const { page, header } = this.props;
    if (!header) {
      return null;
    }
    return (
      <div className={classNames('vcwiz-header', `${page}-page-header`)}>
        {header}
      </div>
    );
  }

  renderBody() {
    const { page, body } = this.props;
    return (
      <div className={classNames('vcwiz-body', `${page}-page-body`)}>
        {body}
      </div>
    );
  }

  renderFooter() {
    const { page, footer } = this.props;
    if (!footer) {
      return null;
    }
    return (
      <div className={classNames('vcwiz-footer', `${page}-page-footer`)}>
        {footer}
      </div>
    );
  }

  render() {
    const { page, showIntro, showLogin, fullScreen, logoLinkPath, openLoginOnLoad, inlineSignup, subtitle, isOutreach } = this.props;
    return (
      <GlobalErrorBoundary>
        <div id="vcwiz" className={classNames('full-screen', 'vcwiz', `toplevel-${page}-page`)}>
          <Header
            subtitle={subtitle}
            showIntro={showIntro}
            showLogin={showLogin}
            openLoginOnLoad={openLoginOnLoad}
            logoLinkPath={logoLinkPath}
            inlineSignup={inlineSignup}
            isOutreach={isOutreach}
          />
          <div className={classNames('vcwiz-page', `${page}-page`, {'full-screen': fullScreen || !showIntro})} onClick={this.onClick}>
            {this.renderHeader()}
            {this.renderBody()}
            {this.renderFooter()}
          </div>
          <Footer />
          {this.props.modal}
        </div>
      </GlobalErrorBoundary>
    );
  }
}