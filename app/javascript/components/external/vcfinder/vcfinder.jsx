import React from 'react';
import { ToastContainer, toast } from 'react-toastify';
import Search from './search.jsx';
import TargetInvestors from './target_investors';
import {emplace, ffetch, remove, flash, fullName} from './utils';
import {TargetInvestorsPath, TargetInvestorStages, TargetInvestorsImportPath} from './constants.js.erb';
import Import from './import';

export default class VCFinder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: [],
      selected: null,
    };
  }

  componentDidMount() {
    ffetch(TargetInvestorsPath)
    .then(targets => this.setState({targets}));
  }


  onNewTarget = (update) => {
    ffetch(TargetInvestorsPath, 'POST', update).then(target => {
      let targets = this.state.targets.concat([target]);
      this.setState({
        selected: targets.length - 1,
        targets,
      });
    });
  };

  onDestroyTarget = (id) => {
    ffetch(TargetInvestorsPath.id(id), 'DELETE').then(() => {
      let targets = remove(this.state.targets, {id});
      this.setState({targets, selected: null});
    });
  };
  
  onInvestorSelect = (investor) => {
    ffetch(TargetInvestorsImportPath, 'POST', {investor: {id: investor.id}})
    .then(target => {
      flash(`Now tracking ${fullName(target)}!`);
      let targets = this.state.targets.concat([target]);
      this.setState({
        selected: targets.length - 1,
        targets,
      })
    });
  };

  onTargetImport = (newTargets) => {
    let targets = this.state.targets.concat(newTargets);
    this.setState({
      selected: null,
      targets,
    })
  };

  onTargetChange = (id, change) => {
    ffetch(TargetInvestorsPath.id(id), 'PATCH', {target_investor: change})
    .then(target => {
      let [targets, i] = emplace(this.state.targets, target);
      if (change.stage) {
        flash(`${fullName(target)} moved to ${TargetInvestorStages[change.stage]}`);
      }
      this.setState({targets, selected: i});
    })
  };

  onStageChange = (stage) => {
    this.setState({stage});
  };

  render() {
    return (
      <div>
        <Search onSelect={this.onInvestorSelect} />
        {<Import onImport={this.onTargetImport} />}
        <TargetInvestors
          targets={this.state.targets}
          stage={this.state.stage}
          selected={this.state.selected}
          onTargetChange={this.onTargetChange}
          onNewTarget={this.onNewTarget}
          onDestroyTarget={this.onDestroyTarget}
          onStageChange={this.onStageChange}
        />
        <ToastContainer position={toast.POSITION.BOTTOM_LEFT} autoClose={4000} />
      </div>
    );
  }
}