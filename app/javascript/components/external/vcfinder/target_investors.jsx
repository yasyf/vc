import React from 'react';
import TargetInvestor from './target_investor';
import Buttons from './buttons';
import {TargetInvestorStages, TargetInvestorStageKeys} from './constants.js.erb';
import {pluckSort} from './utils';

export default class TargetInvestors extends React.Component {
  renderStageButtons() {
    let stages = pluckSort(this.props.targets, 'stage', TargetInvestorStageKeys);
    let labeled = _.zip(stages, _.map(stages, s => TargetInvestorStages[s]));
    return (
      <Buttons
        categories={labeled}
        current={this.props.stage}
        onChange={this.props.onStageChange}
        alwaysShow={true}
        icon="arrow-right"
      />
    );
  }

  render() {
    let targets = _.sortBy(Object.entries(_.groupBy(_.filter(this.props.targets, {stage: this.props.stage}), 'tier')), '1');
    let components = [];
    targets.forEach(([tier, group]) => {
      components.push(<h3 key={`tier-${tier}`}>Priority {tier}</h3>);
      group.forEach(target => components.push(
        <TargetInvestor
          key={target.id}
          open={target.id === this.props.open}
          {...target}
          onTargetChange={this.props.onTargetChange}
        />
      ));
    });
    return (
      <div className="investors">
        {this.renderStageButtons()}
        {components}
      </div>
    );
  }
}