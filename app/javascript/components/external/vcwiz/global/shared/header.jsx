import React from 'react';
import {
  Badge,
  Button,
  TopBar,
  TopBarLeft,
  TopBarRight,
} from 'react-foundation';
import {DiscoverPath,OutreachPath} from '../constants.js.erb';
import {isLoggedIn} from '../utils';
import LoginModal from '../login/login_modal';
import Actions from '../actions';
import classNames from 'classnames';

export default class Header extends React.Component {
  state = {
    loginOpen: false,
    loginStage: 0,
  };

  componentDidMount() {
    Actions.register('login', this.openLogin);
  }

  componentWillUnmount() {
    Actions.unregister('login');
  }

  onClick = () => {
    window.location.href = DiscoverPath;
  };

  openLoginModal = (e, i) => {
    this.setState({loginOpen: true, loginStage: i});
    if (e)
      e.preventDefault();
  };

  closeLoginModal = () => {
    this.setState({loginOpen: false});
  };

  openLogin = e => {
    this.openLoginModal(e, 3);
  };

  openSignup = e => {
    this.openLoginModal(e, 0);
  };

  renderCount() {
    if (!window.gon.founder.conversations) {
      return null;
    }
    return <span>({window.gon.founder.conversations.total})</span>;
  }

  renderRight() {
    if (isLoggedIn()) {
      return (
        <div className="title right">
          <a href={OutreachPath}>
            <h5 className="subtitle nudge-middle">
              Your Conversations {this.renderCount()}
            </h5>
          </a>
          <i className="line-icon fi-widget"/>
        </div>
      );
    } else {
      return (
        <div className="title right">
          Already have an account?
          <a onClick={this.openLogin}>
            <span className="subtitle nudge-right">Log In</span>
          </a>
        </div>
      );
    }
  }

  renderHeader() {
    return (
      <TopBar id="top-bar">
        <TopBarLeft>
          <div className="title left">
            <a href={DiscoverPath}>
              <h3><b>VCWiz</b></h3>
              <h5 className="faded subtitle">Raise Your Seed Round</h5>
            </a>
          </div>
        </TopBarLeft>
        <TopBarRight>
          {this.renderRight()}
        </TopBarRight>
      </TopBar>
    );
  }

  renderBadge(icon) {
    return <Badge><i className={`fi-${icon}`} /></Badge>;
  }

  renderBenefit(name, icon, heading, subheading) {
    return (
      <div className={classNames(name, 'benefit')}>
        {this.renderBadge(icon)}
        <div className="info">
          <div className="heading">{heading}</div>
          <div className="subheading">{subheading}</div>
        </div>
      </div>
    );
  }

  renderBar() {
    if (isLoggedIn()) {
      return null;
    }
    return (
      <TopBar id="signup-bar">
        <div className="space" />
        <div className="signup-content title left">
          <div className="intro">
            <h2 className="subtitle">Raise your seed round with VCWiz.</h2>
            <p className="subtitle">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo viverra blandit.
              In hac habitasse platea dictumst. Etiam mattis placerat augue ut scelerisque. In eget ultricies ipsum
            </p>
          </div>
          <div className="benefits">
            {this.renderBenefit('discover', 'magnifying-glass reversed', '1. Discover', 'Filter or search to find VCs.')}
            {this.renderBenefit('outreach', 'mail', '2. VCWiz Intros', 'Get introduced to participating investors.')}
            {this.renderBenefit('track', 'check', '3. Track', 'All your conversations, organized.')}
          </div>
          <div className="button-wrapper">
            <Button onClick={this.openSignup}>
              Sign Up
            </Button>
          </div>
        </div>
      </TopBar>
    );
  }

  renderModal() {
    if (!this.state.loginOpen) {
      return null;
    }
    return (
      <LoginModal
        isOpen={this.state.loginOpen}
        stage={this.state.loginStage}
        onClose={this.closeLoginModal}
      />
    );
  }

  render() {
    return (
      <div>
        {this.renderModal()}
        <header id="top-header">
          {this.renderHeader()}
          {this.renderBar()}
        </header>
      </div>
    );
  }
}