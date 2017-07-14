import React from 'react';
import Search from './search.jsx';
import TargetInvestors from './target_investors';
import {emplace, ffetch} from './utils';
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
    .then(targets => this.setState({targets}));
  }

  onInvestorSelect = (investor) => {
    ffetch(TargetInvestorsPath, 'POST', {investor: {id: investor.id, tier: this.state.tier}})
    .then(target => this.setState({targets: this.state.targets.concat([target])}));
  };

  onTargetChange = (id, change) => {
    ffetch(`${TargetInvestorsPath}/${id}`, 'PATCH', {target_investor: change})
    .then(target => {
      let targets = emplace(this.state.targets, target);
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
        <TargetInvestors
          targets={this.state.targets}
          tier={this.state.tier}
          onTargetChange={this.onTargetChange}
          onTierChange={this.onTierChange}
        />
      </div>
    );
  }
}