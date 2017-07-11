import React from 'react';
import Search from './search.jsx';
import Investors from './investors.jsx';
import { ffetch } from './utils';
import update from 'immutability-helper';
import { TargetInvestorsPath } from './constants.js.erb';

export default class VCFinder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: [],
      tier: 1,
    };
  }

  componentDidMount() {
    ffetch(TargetInvestorsPath)
    .then(resp => resp.json())
    .then(targets => this.setState({targets}));
  }

  onInvestorSelect = (investor) => {
    ffetch(TargetInvestorsPath, 'POST', {investor: {id: investor.id, tier: this.state.tier}})
    .then(resp => resp.json())
    .then(target => this.setState({targets: this.state.targets.concat([target])}));
  };

  onTargetChange = (id, change) => {
    ffetch(`${TargetInvestorsPath}/${id}`, 'PATCH', {target_investor: change})
    .then(resp => resp.json())
    .then(target => {
      let index = _.findIndex(this.state.targets, {id});
      let targets = update(this.state.targets, {[index]: {$set: target}});
      this.setState({targets});
    })
  };

  onTierChange = (tier) => {
    this.setState({tier});
  };

  render() {
    return (
      <div>
        <Search onSelect={this.onInvestorSelect} />
        <Investors
          targets={this.state.targets}
          tier={this.state.tier}
          onTargetChange={this.onTargetChange}
          onTierChange={this.onTierChange}
        />
      </div>
    );
  }
}