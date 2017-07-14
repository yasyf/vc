import React from 'react';
import TargetInvestor from './target_investor';
import Buttons from './buttons';
import { TargetInvestorStages } from './constants.js.erb';

export default class TargetInvestors extends React.Component {
  renderTierButtons() {
    let tiers = _.sortBy(_.uniq(_.map(this.props.targets, 'tier')));
    let labeled = _.zip(tiers, _.times(tiers.length, _.constant('Tier')));
    return (
      <Buttons
        categories={labeled}
        current={this.props.tier}
        onChange={this.props.onTierChange}
      />
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
      group.forEach(target => components.push(<TargetInvestor key={target.id} {...target} onTargetChange={this.props.onTargetChange} />));
    });

    return (
      <div className="investors">
        {this.renderTierButtons()}
        {components}
      </div>
    );
  }
}