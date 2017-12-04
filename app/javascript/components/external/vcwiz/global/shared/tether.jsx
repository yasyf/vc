import React from 'react';
import TetherComponent from 'react-tether';

export default class Tether extends React.Component {
  render() {
    const { width, className, children } = this.props;
    const clientWidth = this.props.width || (this.target ? this.target.clientWidth : undefined);
    return (
      <TetherComponent
        className={className}
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
        <div ref={target => { this.target = target; }} />
        <div style={{position: 'static', width: clientWidth}}>
          {children}
        </div>
      </TetherComponent>
    );
  }
}