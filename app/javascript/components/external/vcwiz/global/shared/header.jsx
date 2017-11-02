import React from 'react';
import {
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

  openLogin = e => {
    this.setState({loginOpen: true});
    if (e)
      e.preventDefault();
  };

  closeLogin = () => {
    this.setState({loginOpen: false});
  };

  renderCount() {
    if (!window.gon.founder.conversation_count) {
      return null;
    }
    return <span>({window.gon.founder.conversation_count})</span>;
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
      <header>
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
      </header>
    );
  }

  renderModal() {
    if (!this.state.loginOpen) {
      return null;
    }
    return (
      <LoginModal
        isOpen={this.state.loginOpen}
        onClose={this.closeLogin}
      />
    );
  }

  render() {
    return (
      <div>
        {this.renderModal()}
        {this.renderHeader()}
      </div>
    );
  }
}