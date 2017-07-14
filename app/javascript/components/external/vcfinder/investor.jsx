import React from 'react';
import InvestorHead from './investor/head';
import InvestorBody from './investor/body';

export default class Investor extends React.Component {
  onChange = (update) => {
    this.props.onChange(this.props.id, update);
  };

  render() {
    return (
      <div className="card float-center investor">
        <InvestorHead {...this.props} onChange={this.onChange} />
        <InvestorBody {...this.props} onChange={this.onChange} />
      </div>
    );
  }
}