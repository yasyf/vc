import React from 'react';

export default class Tutorial extends React.Component {
  static defaultProps = {
    playing: true,
  };

  state = {
    loaded: false,
  };

  componentWillMount() {
    this.interval = setInterval(() => {
      if (document.readyState === 'complete') {
        this.setState({loaded: true});
        clearInterval(this.interval);
      }
    }, 500);
  }

  componentWillUnmount() {
    clearInterval(this.interval);
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