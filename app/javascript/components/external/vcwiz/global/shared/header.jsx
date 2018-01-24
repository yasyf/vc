import React from 'react';
import {
  Badge,
  Button,
  Colors,
  TopBar,
  TopBarLeft,
  TopBarRight,
} from 'react-foundation';
import {DiscoverPath, OutreachPath, LoginPath} from '../constants.js.erb';
import Store from '../store';
import {isLoggedIn, isMobile} from '../utils';
import LoginModal from '../login/login_modal';
import Actions from '../actions';
import classNames from 'classnames';
import OutreachBar from './outreach_bar';
import FounderSettingsModal from '../settings/founder_settings_modal';
import Flashes from './flashes';
import Logo from './logo';

export default class Header extends React.Component {
  static defaultProps = {
    showLogin: true,
    openLoginOnLoad: false,
    logoLinkPath: DiscoverPath,
  };

  constructor(props) {
    super(props);

    this.state = {
      loginOpen: props.openLoginOnLoad,
      settingsOpen: false,
      loginStage: 0,
      showIntro: true,
      founder: Store.get('founder', {}),
    };
  }

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
    this.openLoginModal(e, 4);
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

  goToLogin = () => {
    window.location.href = LoginPath;
  };

  renderCount() {
    if (!this.state.founder.conversations) {
      return null;
    }
    return <span>My Conversations ({this.state.founder.conversations.total})</span>;
  }

  renderRight() {
    const { showLogin, inlineSignup, isOutreach } = this.props;
    if (isLoggedIn()) {
      return (
        <div className="title right">
          <a href={isOutreach ? DiscoverPath : OutreachPath}>
            <h5 className="subtitle nudge-middle">
              {isOutreach ? 'Discover More Investors' : this.renderCount()}
            </h5>
          </a>
          <a onClick={this.openSettingsModal}>
            <i className="line-icon fi-widget"/>
          </a>
        </div>
      );
    } else if (showLogin) {
      if (inlineSignup) {
        return (
          <div className="title right">
            Founder?
            <a onClick={this.openSignup}>
              <span className="subtitle nudge-right">Sign Up For VCWiz!</span>
            </a>
          </div>
        );
      } else {
        return (
          <div className="title right">
            Already have an account?
            <a href={LoginPath}>
              <span className="subtitle nudge-right">Log In</span>
            </a>
          </div>
        );
      }
    } else {
      return null;
    }
  }

  renderHeader() {
    return (
      <TopBar id="top-bar">
        <TopBarLeft>
          <div className="title left">
            <a href={this.props.logoLinkPath}>
              <Logo />
              <h5 className="faded subtitle">{this.props.subtitle}</h5>
            </a>
            <Flashes alert={!isMobile()} />
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

  renderExtraInfo() {
    if (isMobile()) {
      return (
        <div>
          VCWiz is not optimized for your phone!<br />
          Visit vcwiz.co on your desktop to sign up.
        </div>
      );
    } else {
      return (
        <span>
          VCWiz is the easiest way to discover relevant investors, get introduced, and keep track of your conversations.
          {' '}
          <a onClick={this.openSignup}>Sign up for conversation tracking, email integrations, and personalized recommendations!</a>
        </span>
      );
    }
  }

  renderButton() {
    if (isMobile()) {
      return (
        <Button onClick={this.goToLogin} color={Colors.SUCCESS}>
          Log In{isMobile() ? ' (Existing User)' : ''}
        </Button>
      );
    } else {
      return (
        <Button onClick={this.openSignup} color={Colors.SUCCESS}>
          Sign Up
        </Button>
      );
    }
  }

  renderButtonWrapper() {
    if (this.props.inlineSignup) {
      return null;
    }
    return (
      <div className="button-wrapper">
        {this.renderButton()}
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
            <p className="subtitle extra-info">
              {this.renderExtraInfo()}
            </p>
          </div>
          <div className="benefits">
            {this.renderBenefit('discover', 'magnifying-glass reversed', '1. Discover', 'Browse or search to find investors.')}
            {this.renderBenefit('outreach', 'mail', '2. VCWiz Intros', 'Get introduced to participating investors.')}
            {this.renderBenefit('track', 'check', '3. Track', 'Organize all your fundraising conversations.')}
          </div>
          {this.renderButtonWrapper()}
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
      <FounderSettingsModal
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