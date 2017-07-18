import React from 'react';
import Search from './search.jsx';
import TargetInvestors from './target_investors';
import {emplace, ffetch, pluckSort} from './utils';
import {TargetInvestorsPath, TargetInvestorStageKeys} from './constants.js.erb';

export default class VCFinder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: [],
      stage: TargetInvestorStageKeys[0],
    };
  }

  componentDidMount() {
    ffetch(TargetInvestorsPath)
    .then(targets => this.setState({targets, stage: this.defaultStage(targets)}));
  }

  defaultStage(targets) {
    let stages = pluckSort(targets, 'stage', TargetInvestorStageKeys);
    return stages[0] || TargetInvestorStageKeys[0];
  }
  
  onInvestorSelect = (investor) => {
    ffetch(TargetInvestorsPath, 'POST', {investor: {id: investor.id}})
    .then(target => this.setState({targets: this.state.targets.concat([target])}));
  };

  onTargetChange = (id, change) => {
    ffetch(`${TargetInvestorsPath}/${id}`, 'PATCH', {target_investor: change})
    .then(target => {
      let targets = emplace(this.state.targets, target);
      this.setState({targets});
    })
  };

  onStageChange = (stage) => {
    this.setState({stage});
  };

  render() {
    return (
      <div>
        <Search onSelect={this.onInvestorSelect} />
        <TargetInvestors
          targets={this.state.targets}
          stage={this.state.stage}
          onTargetChange={this.onTargetChange}
          onStageChange={this.onStageChange}
        />
      </div>
    );
  }
}