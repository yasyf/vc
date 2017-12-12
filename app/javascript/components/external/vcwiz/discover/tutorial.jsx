import React from 'react';
import Store from '../global/store';

export default class Tutorial extends React.Component {
  static defaultProps = {
    playing: true,
  };

  state = {
    loaded: false,
  };

  componentWillMount() {
    this.subscription = Store.subscribe('isReady', () => {
      this.setState({loaded: true});
    });
    this.setState({loaded: Store.get('isReady', false)});
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  render() {
    const { loaded } = this.state;
    const { n, playing, caption } = this.props;
    const style = {
      animationPlayState: (playing && loaded) ? 'running' : 'paused',
    };
    return (
      <div className="tutorials">
        <div className={`tutorial tutorial-${n}`} style={style} />
        <h5>{caption}</h5>
      </div>
    )
  }
}