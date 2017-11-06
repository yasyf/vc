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
import {isLoggedIn} from '../utils';
import LoginModal from '../login/login_modal';
import Actions from '../actions';

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

  renderBar() {
    if (isLoggedIn()) {
      return null;
    }
    return (
      <TopBar id="signup-bar">
        <TopBarLeft>
          <div className="title left">
            <div className="subtitle">Raise your seed round.</div>
            <div className="benefits">
              <Badge color={Colors.SECONDARY}>1</Badge>
              <span className="benefit">Discover firms</span>
              <Badge color={Colors.SECONDARY}>2</Badge>
              <span className="benefit">Research investors</span>
              <Badge color={Colors.SECONDARY}>3</Badge>
              <span className="benefit">Get introduced, track conversations</span>
            </div>
          </div>
        </TopBarLeft>
        <TopBarRight>
          <div className="title right">
            <Button color={Colors.SECONDARY} onClick={this.openSignup} isHollow>
              Sign Up
            </Button>
          </div>
        </TopBarRight>
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
        <header>
          {this.renderHeader()}
          {this.renderBar()}
        </header>
      </div>
    );
  }
}