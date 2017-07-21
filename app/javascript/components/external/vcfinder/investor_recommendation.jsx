import React from 'react';
import InvestorHead from './investor/head';
import InvestorBody from './investor/body';

export default class InvestorRecommendation extends React.Component {
  onSelect = () => {
    this.props.onSelect(this.props.id)
  };

  renderButton() {
    return (
      <div className="float-center text-center">
        <button type="button" className="hollow button" onClick={this.onSelect}>
          I Want To Chat!
        </button>
      </div>
    );
  }

  render() {
    return (
      <div className="card float-center investor">
        <InvestorHead {...this.props} />
        <InvestorBody {...this.props}  readonly={true} />
        <div className="card-section card-section-multi">
          {this.renderButton()}
        </div>
      </div>
    );
  }
}