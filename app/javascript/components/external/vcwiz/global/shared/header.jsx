import React from 'react';
import {
  Badge,
  Button,
  Colors,
  TopBar,
  TopBarLeft,
  TopBarRight,
} from 'react-foundation';
import {DiscoverPath,OutreachPath} from '../constants.js.erb';
import Store from '../store';
import {isLoggedIn} from '../utils';
import LoginModal from '../login/login_modal';
import Actions from '../actions';
import classNames from 'classnames';
import OutreachBar from './outreach_bar';
import SettingsModal from '../settings/settings_modal';

export default class Header extends React.Component {
  static defaultProps = {
    showLogin: true,
  };

  state = {
    loginOpen: false,
    settingsOpen: false,
    loginStage: 0,
    showIntro: true,
    founder: Store.get('founder', {}),
  };

  componentWillMount() {
    this.subscription = Store.subscribe('founder', founder => this.setState({founder}));
  }

  componentDidMount() {
    Actions.register('login', this.openLogin);
    Actions.register('signup', this.openSignup);
    Actions.register('settings', this.openSettingsModal);
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
    Actions.unregister('login');
    Actions.unregister('signup');
    Actions.unregister('settings');
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

  openSettingsModal = e => {
    this.setState({settingsOpen: true});
  };

  closeSettingsModal = e => {
    this.setState({settingsOpen: false});
  };

  renderCount() {
    if (!this.state.founder.conversations) {
      return null;
    }
    return <span>({this.state.founder.conversations.total})</span>;
  }

  renderRight() {
    if (isLoggedIn()) {
      return (
        <div className="title right">
          <a href={OutreachPath}>
            <h5 className="subtitle nudge-middle">
              My Conversations {this.renderCount()}
            </h5>
          </a>
          <a onClick={this.openSettingsModal}>
            <i className="line-icon fi-widget"/>
          </a>
        </div>
      );
    } else if (this.props.showLogin) {
      return (
        <div className="title right">
          Already have an account?
          <a onClick={this.openLogin}>
            <span className="subtitle nudge-right">Log In</span>
          </a>
        </div>
      );
    } else {
      return null;
    }
  }

  renderHeader() {
    return (
      <TopBar id="top-bar">
        <TopBarLeft>
          <div className="title left">
            <a href={DiscoverPath}>
              <h3><b>VCWiz</b></h3>
              <h5 className="faded subtitle">{this.props.subtitle}</h5>
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

  renderLoggedOutBar() {
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
            <Button onClick={this.openSignup} color={Colors.SUCCESS}>
              Sign Up
            </Button>
          </div>
        </div>
      </TopBar>
    );
  }

  renderLoggedInBar() {
    return (
      <TopBar id="outreach-bar">
        <div className="outreach-bar-content">
          <OutreachBar />
        </div>
      </TopBar>
    );
  }

  renderBar() {
    if (!this.props.showIntro) {
      return null;
    } else if (isLoggedIn()) {
      return this.renderLoggedInBar();
    } else {
      return this.renderLoggedOutBar();
    }
  }

  renderLoginModal() {
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

  renderSettingsModal() {
    if (!this.state.settingsOpen) {
      return null;
    }
    return (
      <SettingsModal
        isOpen={this.state.settingsOpen}
        onClose={this.closeSettingsModal}
      />
    );
  }

  render() {
    return (
      <div>
        {this.renderLoginModal()}
        {this.renderSettingsModal()}
        <header id="top-header">
          {this.renderHeader()}
          {this.renderBar()}
        </header>
      </div>
    );
  }
}