import React from 'react';
import TetherComponent from 'react-tether';

export default class Tether extends React.Component {
  render() {
    return (
      <TetherComponent
        className={this.props.className}
        renderElementTo="body"
        attachment="top left"
        targetAttachment="top left"
        constraints={[{
          to: 'window',
          attachment: 'together',
          pin: ['top']
        }]}
        optimizations={{ gpu: false }}
      >
        <div></div>
        <div style={{position: 'static', width: this.props.width}}>
          {this.props.children}
        </div>
      </TetherComponent>
    );
  }
}