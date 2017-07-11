import React from 'react';
import Investor from './investor.jsx';
import { TargetInvestorStages } from './constants.js.erb';

export default class Investors extends React.Component {
  renderTierButtons() {
    let tiers = _.sortBy(_.uniq(_.map(this.props.targets, 'tier')));
    if (tiers.length === 0 || (tiers.length === 1 && tiers[0] === this.props.tier)) {
      return null;
    }
    let buttons = tiers.map(tier =>
      <button
        type="button"
        className="button tier-button"
        key={tier}
        onClick={() => this.props.onTierChange(tier)}
      >
        Tier {tier}
      </button>
    );
    return (
      <div className="tier-buttons float-center text-center">
        {buttons}
      </div>
    );
  }

  render() {
    let targets = _.groupBy(_.filter(this.props.targets, {tier: this.props.tier}), 'stage');
    let components = [];
    Object.entries(TargetInvestorStages).forEach(([key, title]) => {
      let group = targets[key];
      if (!group) {
        return;
      }
      components.push(<h3 key={key}>{title}</h3>);
      group.forEach(target => components.push(<Investor key={target.id} target={target} onTargetChange={this.props.onTargetChange} />));
    });

    return (
      <div className="investors">
        {this.renderTierButtons()}
        {components}
      </div>
    );
  }
}