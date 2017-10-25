import React from 'react';
import {
  TopBar,
  TopBarLeft,
  TopBarRight,
} from 'react-foundation';
import {DiscoverPath,OutreachPath} from '../constants.js.erb';

export default class Header extends React.Component {
  onClick = () => {
    window.location.href = DiscoverPath;
  };

  renderCount() {
    if (!gon.founder.conversation_count) {
      return null;
    }
    return (
      <span>
        ({gon.founder.conversation_count})
        <i className="line-icon fi-widget"/>
      </span>
    );
  }

  render() {
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
            <div className="title right">
              <a href={OutreachPath}>
                <h5 className="subtitle">Your Conversations {this.renderCount()}</h5>
              </a>
            </div>
          </TopBarRight>
        </TopBar>
      </header>
    )
  }
}