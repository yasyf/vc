import React from 'react';
import Store from '../store';
import Actions from '../actions';
import classNames from 'classnames';
import Flash from './flash';
import Tether from './tether';

export default class Flashes extends React.Component {
  state = {
    showFlashes: true,
    ignoreNextClick: false,
    flashes: window.flashes,
    alert: true,
  };

  componentDidMount() {
    Actions.register('flash', this.addFlash);
  }

  componentWillMount() {
    this.subscription = Store.subscribe('lastClick', e => {
      const { ignoreNextClick, showFlashes } = this.state;
      if (ignoreNextClick) {
        this.setState({ignoreNextClick: false});
      } else if (showFlashes) {
        this.setState({showFlashes: false});
      }
    });
    this.subscription2 = Store.subscribe('lastScroll', e => {
      const { ignoreNextClick, showFlashes } = this.state;
      if (showFlashes && !ignoreNextClick) {
        this.setState({showFlashes: false});
      }
    });
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
    Store.unsubscribe(this.subscription2);
  }

  onClose = i => () => {
    const { flashes } = this.state;
    this.setState({flashes: _.without(flashes, flashes[i])});
  };

  addFlash = flash => {
    this.setState({flashes: this.state.flashes.concat([flash]), showFlashes: true, ignoreNextClick: true});
  };

  toggleFlashes = e => {
    this.setState({showFlashes: !this.state.showFlashes});
    e.stopPropagation();
  };

  renderFlashes() {
    const { flashes, showFlashes } = this.state;
    if (!showFlashes) {
      return null;
    }
    return (
      <div className="flashes-alert">
        <div className="arrow"/>
        <div className="wrapper">
          {_.reverse(flashes.map((flash, i) => <Flash key={i} {...flash} showClose={false} onClose={this.onClose(i)}/>))}
        </div>
      </div>
    );
  }

  render() {
    const { alert } = this.props;
    const { flashes } = this.state;
    if (!flashes.length) {
      return null;
    }
    if (alert) {
      return [
        <a key="icon" className="alert-icon" onClick={this.toggleFlashes}>
          <i className={classNames('line-icon', 'fi-alert', _.last(flashes).type)}/>
        </a>,
        <Tether key="flashes" targetClassName="flashes-alert-tether-target" className="flashes-alert-tether">
          {this.renderFlashes()}
        </Tether>,
      ];
    } else {
      return (
        <div className="flashes">
          {this.renderFlashes()}
        </div>
      )
    }
  }
}