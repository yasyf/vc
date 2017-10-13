import React from 'react';
import {
  TopBar,
  TopBarLeft,
} from 'react-foundation';
import {DiscoverPath} from '../constants.js.erb';

export default class Header extends React.Component {
  onClick = () => {
    window.location.href = DiscoverPath;
  };

  render() {
    return (
      <header>
        <TopBar id="top-bar">
          <TopBarLeft>
            <div className="title" onClick={this.onClick}>
              <h3><b>VCWiz</b></h3>
              <h5 className="faded subtitle">Raise Your Seed Round</h5>
            </div>
          </TopBarLeft>
        </TopBar>
      </header>
    )
  }
}