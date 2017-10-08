import React from 'react';
import {
  TopBar,
  TopBarLeft,
  Menu,
  MenuItem,
  Row,
  Column,
} from 'react-foundation';

export default class Header extends React.Component {
  render() {
    return (
      <header>
        <TopBar id="top-bar">
          <TopBarLeft>
            <div className="title">
              <h3><b>VCWiz</b></h3>
              <h5 className="faded subtitle">Raise Your Seed Round</h5>
            </div>
          </TopBarLeft>
        </TopBar>
      </header>
    )
  }
}